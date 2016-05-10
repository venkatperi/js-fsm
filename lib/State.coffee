OP = require './op'
Transition = require './Transition'

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
    if @transition t.to
      throw new Error "transition to state #{t.to} from #{@name} already exists"
    @transition t.to, t

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
    
