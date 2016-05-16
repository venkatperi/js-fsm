OP = require './op'
Transition = require './Transition'
{ItemExistsError, InvalidOperationError} = require './util/errors'
flatten = require 'flatten'

module.exports = class State

  constructor : ( @name, @target ) ->
    @_transitions = {}
    @_outputs = []

  addOutputs : ( outputs, invert ) =>
    for o in outputs
      signal = o.id.name
      inv = o.invert
      inv = !inv if invert
      input = OP.input !inv
      @_outputs.push OP.write input, @target, signal
    @

  addTransition : ( t ) =>
    ### !pragma coverage-skip-next ###
    to = t.to.id.name
    if @transition to
      throw ItemExistsError
        name : "#{to}"
        itemType : 'transition'
    @transition to, new Transition t, @target

  transition : ( state, value )  =>
    return @_transitions[ state ] if arguments.length is 1
    @_transitions[ state ] = value
    @

  clock : =>
    matching = (t for own to, t of @_transitions when t.enabled())
    ### !pragma coverage-skip-next ###
    if matching.length > 1
      throw InvalidOperationError
        details : "Multiple transitions possible from state #{@}"
    matching[ 0 ]

  writeOutputs : =>
    o.output() for o in @_outputs
    @

