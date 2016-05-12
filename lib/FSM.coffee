{EventEmitter} = require 'events'
flatten = require 'flatten'
prop = require 'prop-it'
State = require './State'
_ = require 'lodash'
{MissingOptionError} = require './util/errors'

collect = ( target, sources... ) ->
  sources = flatten sources
  for s in sources when s and s isnt '*'
    target.add s.replace('!', '').trim()
  target

class FSM extends EventEmitter

  constructor : ( opts = {} ) ->
    ### !pragma coverage-skip-next ###
    for opt in [ 'initial', 'transitions' ]
      throw MissingOptionError name : opt unless opts[ opt ]

    @_states = {}
    @_data = {}
    opts.outputs ?= {}
    @initStates opts
    @initOutputs opts
    @initSignals opts
    @initTransitions opts

    prop @,
      name : 'currentState'
      getter : => @state @current()
      setter : ( v ) =>
        v.writeOutputs()
        @current v.name

    prop @, name : 'current', store : @_data, field : '_current'
    @currentState @state opts.initial

  initStates : ( opts ) =>
    states = new Set()
    collect states, t.from, t.to for t in opts.transitions
    states.add opts.initial
    states.forEach ( s ) => @_states[ s ] = new State s, @

  initOutputs : ( opts ) =>
    outputs = @getOutputs opts
    @state(s).outputs outputs[ s ] for s in Object.keys @_states

  getOutputs : ( opts, allStates ) ->
    states = Object.keys @_states
    outputs = {}
    add = ( list, out ) ->
      for s in list
        outputs[ s ] ?= []
        outputs[ s ].push out

    for own state, out of opts.outputs
      state = state.trim()
      [state, op] = [ state[ 1.. ], state[ 0 ] ] if state[ 0 ] in [ '!', '^' ]
      list = (s.trim() for s in state.split(','))
      invertedList = (k for k in states when k not in list) if op?
      if op is '^'
        invertedOutputs = for o in out
          if o[ 0 ] is '!' then o[ 1.. ] else "!#{o}"
        add invertedList, invertedOutputs
      list = invertedList if op is '!'
      add list, out
    outputs

  initSignals : ( opts ) =>
    signals = new Set()
    collect signals, t.inputs for t in opts.transitions
    collect signals, out for own state, out of opts.outputs

    signals.forEach ( i ) =>
      n = _.capitalize i
      prop @, name : i, store : @_data
      @[ "set#{n}" ] = => @[ i ] true
      @[ "reset#{n}" ] = => @[ i ] false
      @[ i ] false

  initTransitions : ( opts ) =>
    for t in opts.transitions
      @state(f).addTransition t for f in flatten [ t.from ]

  state : ( name, value ) =>
    ### !pragma coverage-skip-block ###
    return @_states[ name ] if arguments.length is 1
    @_states[ name ] = value
    @

  reset : ( names... ) =>
    for n in names
      @[n] false
    @

  set : ( names... ) =>
    @[ n ] true for n in names
    @

  load : ( data ) =>
    _.assignIn @_data, data
    @

  save : =>
    _.cloneDeep @_data

  clock : =>
    try
      @doClock()
    catch err
      @emit "error", err
    @

  doClock : =>
    ### !pragma coverage-skip-next ###
    return if @_onedge

    @_onedge = true
    next = @currentState().clock()
    if next
      to = next.to
      from = @current()
      desc = next.description

      state = @state to
      @currentState state
      @emit "state", to, from, desc
    else
      @emit "noop"

    @_onedge = false
    return next?.to

module.exports = FSM