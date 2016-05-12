OP = require './op'
Transition = require './Transition'
{ItemExistsError, InvalidOperationError} = require './util/errors'
flatten = require 'flatten'

module.exports = class State

  constructor : ( @name, @target ) ->
    @_transitions = {}
    @_outputs = []

  outputs : ( list ) =>
    return @_outputs if arguments.length is 0 or !list
    for o in flatten list
      [signal, unary] = OP.normalize o
      input = OP.input true
      input = OP.not input if unary is 'not'
      @_outputs.push OP.write input, @target, signal
    @

  addTransition : ( opts ) =>
    ### !pragma coverage-skip-next ###
    if @transition opts.to
      throw ItemExistsError
        name : "to #{opts.to}"
        itemType : 'transition'
    @transition opts.to, new Transition opts, @target

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
    o.output() for o in @outputs()
    @

