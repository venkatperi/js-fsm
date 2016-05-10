{EventEmitter} = require 'events'
flatten = require 'flatten'
prop = require 'prop-it'
State = require './State'
_ = require 'lodash'
{Throw, MissingOptionError} = require './util/errors'

collect = ( target, sources... ) ->
  sources = flatten sources
  for s in sources
    unless !s or s is '*'
      s = s.replace '!', ''
      target.add s.trim()
  target

class FSM extends EventEmitter

  constructor : ( opts = {} ) ->
    for opt in [ 'initial', 'transitions' ]
      Throw( MissingOptionError name : opt ).unless opts[ opt ]

    @_states = {}
    @_data = {}

    opts.outputs ?= {}

    @initStates opts
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

    allStates = Object.keys @_states
    outputs = @getOutputs opts, allStates

    states.forEach ( s ) =>
      state = @state s
      if outputs[ s ]
        o = [ outputs[ s ] ]
        state.outputs flatten o

  getOutputs : ( opts, allStates ) ->
    outputs = {}
    for own state, out of opts.outputs
      do ( state, out ) ->
        state = state.trim()
        if state[ 0 ] is '!'
          invert = state[ 0 ] is '!'
          state = state[ 1.. ]
        list = (s.trim() for s in state.split( ',' ))
        if invert
          list = (k for k in allStates when k not in list)
        for s in list
          outputs[ s ] ?= []
          outputs[ s ].push out
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
      from = flatten [ t.from ]
      @state( f ).addTransition t for f in from

  state : ( name, value ) =>
    return @_states[ name ] if arguments.length is 1
    @_states[ name ] = value
    @

  reset : ( names... ) =>
    @[ n ] false for n in names
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