{EventEmitter} = require 'events'
flatten = require 'flatten'
prop = require 'prop-it'
State = require './State'
WILDCARD = '*'

collect = ( target, sources... ) ->
  sources = flatten sources
  for s in sources
    unless s is WILDCARD or !s
      s = s.replace '!', ''
      target.add s.trim()
  target

class FSM extends EventEmitter

  constructor : ( opts = {} ) ->
    for opt in [ 'initial', 'transitions' ]
      throw new Error "missing option: '#{opt}'" unless opts[ opt ]?

    @_states = {}
    @_signals = {}

    opts.outputs ?= {}

    @initStates opts
    @initSignals opts
    @initTransitions opts

    prop @, name : 'currentState'
    prop @, name : 'current'
    @on "changed:currentState", ( c ) ->
      @current c?.name

    @currentState @state opts.initial

  initStates : ( opts ) =>
    states = new Set()
    collect states, t.from, t.to for t in opts.transitions
    states.add opts.initial

    states.forEach ( s ) =>
      state = @_states[ s ] = new State s, @
      state.outputs opts.outputs[ s ]

  initSignals : ( opts ) =>
    signals = new Set()
    collect signals, t.inputs for t in opts.transitions
    collect signals, out for own state, out of opts.outputs

    signals.forEach ( i ) =>
      prop @, name : i, store : @_signals
      @[ i ] false

  initTransitions : ( opts ) =>
    for t in opts.transitions
      from = flatten [ t.from ]
      @state( f ).addTransition t for f in from

  state : ( name, value ) =>
    return @_states[ name ] if arguments.length is 1
    @_states[ name ] = value
    @

  clock : =>
    return if @_onedge

    @_onedge = true
    next = @currentState().clock()
    if next
      to = next.to
      from = @current()
      desc = next.description

      @emit "leave", from, to, desc
      state = @state to
      @currentState state
      for o in state.outputs()
        o.output() # writes on pull

      @emit "enter", from, to, desc
    else
      @emit "noop"

    @_onedge = false

    return next?.to 

module.exports = FSM