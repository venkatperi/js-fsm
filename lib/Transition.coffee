OP = require './op'
{MissingOptionError, NotPermittedError} = require './util/errors'
_ = require 'lodash'

module.exports = class Transition
  constructor : ( t, target ) ->
    @to = t.to.id.name
    inputs = t.findByType 'Input'
    @op = OP.and(OP.input target, i for i in inputs)
    @description = @op.desc()

  enabled : => @op.output()
