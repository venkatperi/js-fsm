OP = require './op'
flatten = require 'flatten'
{MissingOptionError, NotPermittedError} = require './util/errors'

module.exports = class Transition
  constructor : ( opts, target ) ->
    ### !pragma coverage-skip-next ###
    throw MissingOptionError name : 'to' unless opts.to

    ### !pragma coverage-skip-next ###
    if Array.isArray opts.to
      throw NotPermittedError
        details : 'Can\'t have multiple transitions for same' +
          '<state,input> tuple'

    ### !pragma coverage-skip-next ###
    if opts.to is '*'
      throw NotPermittedError
        details : 'transition target cannot be a wildcard'

    @to = opts.to
    inputs = flatten [ opts.inputs or [] ]
    @op = OP.and(OP.input target, i for i in inputs)
    @description = opts.description or @op.desc()

  enabled : => @op.output()
