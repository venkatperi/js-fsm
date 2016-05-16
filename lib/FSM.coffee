{EventEmitter} = require 'events'
flatten = require 'flatten'
prop = require 'prop-it'
State = require './State'
_ = require 'lodash'
{MissingOptionError} = require './util/errors'
parser = require '../../js-fsm-parser'
NodeCache = require 'node-cache'

class FSM extends EventEmitter

  constructor : ( opts = {} ) ->
    @_data = {}

  init : =>
    prop @,
      name : 'currentState'
      getter : => @state @current()
      setter : ( v ) =>
        v.writeOutputs()
        @current v.name

    prop @, name : 'current', store : @_data, field : '_current'
    initialState = @root.initial.findByType 'InitialState'
    @currentState @state initialState[ 0 ].id.name
    @

  load : ( str ) =>
    @root = parser(str)
    {states, signals, transitions, stateOutputs} = @_findAstObjects @root

    @_initStates states
    @_initSignals signals
    @_initTransitions transitions
    @_initOutputs stateOutputs
    @init()

  _initOutputs : ( stateOutputs ) =>
    allStateNames = @_stateNames()
    for so in stateOutputs
      stateNames = _.map so.findByType('State'), ( x ) -> x.id.name
      outputs = so.findByType 'Output'
      regular = !so.states.invert || so.states.iff
      inverted = so.states.invert || so.states.iff

      if regular
        @state(s).addOutputs outputs for s in stateNames

      if inverted
        invStateNames = _.difference allStateNames, stateNames
        @state(s).addOutputs outputs, true for s in invStateNames

  _initStates : ( states ) =>
    @_states ?= {}
    @_states[ s ] = new State s, @ for s in states

  _findAstObjects : ( root ) ->
    nodes = {}
    for type in [ 'state', 'input', 'output' ]
      t = _.capitalize type
      nodes[ "#{type}s" ] = _.map root.findUniqByType(t), ( x ) -> x.id.name
    nodes.signals = _.uniq _.flatten [ nodes.inputs, nodes.outputs ]
    nodes.transitions = root.findByType 'Transition'
    nodes.stateOutputs = root.findByType 'StateOutput'
    nodes

  _initTransitions : ( transitions ) =>
    for t in transitions
      from = t.from.findUniqByType 'State'
      @state(f.id.name).addTransition t for f in from

  _initSignals : ( signals ) =>
    for i in signals
      n = _.capitalize i
      prop @, name : i, store : @_data
      @[ "set#{n}" ] = => @[ i ] true
      @[ "reset#{n}" ] = => @[ i ] false
      @[ i ] false

  states : => @_states

  _stateNames : =>
    _.map @states(), ( x ) -> x.name

  state : ( name, value ) =>
    ### !pragma coverage-skip-block ###
    return @_states[ name ] if arguments.length is 1
    @_states[ name ] = value
    @

  reset : ( names... ) =>
    for n in names
      @[ n ] false
    @

  set : ( names... ) =>
    @[ n ] true for n in names
    @

  #load : ( data ) =>
  #  _.assignIn @_data, data
  #  @

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