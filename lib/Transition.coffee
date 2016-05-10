OP = require './op'
flatten = require 'flatten'
{Throw, MissingOptionError, NotPermittedError} = require './util/errors'

module.exports = class Transition
  constructor : ( opts, target ) ->
    Throw MissingOptionError name : 'to'
    .unless opts.to

    Throw( NotPermittedError
      details : 'Can\'t have multiple transitions for same' +
        '<state,input> tuple' )
    .if Array.isArray opts.to

    opts.inputs ?= []
    inputs = flatten [ opts.inputs ]
    op = OP.and( OP.input target, i for i in inputs )
    opts.description ?= op.desc()
    to = opts.to

    Throw( NotPermittedError
      details : 'transition target cannot be a wildcard' )
    .if to is '*'

    @to = to
    @op = op
    @description = opts.description
