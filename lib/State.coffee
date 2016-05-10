OP = require './op'
flatten = require 'flatten'

module.exports = class State
  constructor : ( @name, @target ) ->
    @_transitions = {}
    @_outputs = []

  outputs : ( list ) =>
    return @_outputs if arguments.length is 0 or !list
    for o in list
      [signal, unary] = OP.normalize o
      input = OP.input true
      input = OP.not input if unary is 'not'
      @_outputs.push OP.write input, @target, signal

  addTransition : ( t ) =>
    t.inputs ?= []
    throw new Error "Transition is missing 'to' state" unless t.to
    if Array.isArray t.to
      throw new Error "Can't have multiple transitions for same" +
          "<state,input> tuple"
    op = OP.and( OP.input @target, i for i in t.inputs )
    t.description ?= op.desc()

    to = t.to
    if @transition to
      throw new Error "transition to state #{to} from #{@name} already exists"

    if to is '*'
      throw new Error "Don't know how to transition to wildcard/*"

    @transition to,
      to : to
      op : op
      description : t.description

  transition : ( state, value )  =>
    return @_transitions[ state ] if arguments.length is 1
    @_transitions[ state ] = value
    @

  clock : =>
    matching = []
    for own to, t of @_transitions
      matching.push t if t.op.output()
    if matching.length > 1
      throw new Error "Multiple transitions possible from state #{@}"
    matching[ 0 ]
    
