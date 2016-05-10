OP = require './op'
flatten = require 'flatten'

module.exports = class Transition
  constructor : ( opts, target ) ->
    throw new Error "Transition is missing 'to' state" unless opts.to
    if Array.isArray opts.to
      throw new Error 'Can\'t have multiple transitions for same' +
          '<state,input> tuple'

    opts.inputs ?= []
    inputs = flatten [ opts.inputs ]
    op = OP.and( OP.input target, i for i in inputs )
    opts.description ?= op.desc()
    to = opts.to


    if to is '*'
      throw new Error "Don't know how to transition to wildcard/*"

    @to = to
    @op = op
    @description = opts.description
