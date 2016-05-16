OP = require './op'
flatten = require 'flatten'
{MissingOptionError, NotPermittedError} = require './util/errors'
_ = require 'lodash'

findByType = ( fsm, type ) ->
  _.uniq (s.id.name for s in fsm.findByType type)

module.exports = class Transition
  constructor : ( t, target ) ->
    @to = t.to.id.name
    inputs = t.findByType 'Input'
    @op = OP.and(OP.input target, i for i in inputs)
    @description = @op.desc()

  enabled : => @op.output()
