OP = require './op'
Transition = require './Transition'
{Throw, ItemExistsError, InvalidOperationError} = require './util/errors'

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

  addTransition : ( opts ) =>
    t = new Transition opts, @target
    Throw ItemExistsError name : "to #{t.to}", itemType : 'transition'
    .if @transition t.to
    @transition t.to, t

  transition : ( state, value )  =>
    return @_transitions[ state ] if arguments.length is 1
    @_transitions[ state ] = value
    @

  clock : =>
    matching = []
    for own to, t of @_transitions
      matching.push t if t.op.output()
    Throw( InvalidOperationError
      details : "Multiple transitions possible from state #{@}" )
    .if matching.length > 1
    matching[ 0 ]

  writeOutputs : =>
    for o in @outputs()
      o.output() # writes on pull
    
