fs = require 'fs'
path = require 'path'
jsFSM = require '../../index'

step = ( fsm, opts ) ->
  fsm[ k ] v for own k,v of opts.i
  fsm.clock()
  fsm.current().should.equal opts.s
  fsm[ k ]().should.equal v for own k,v of opts.o

steps = ( fsm, inputs ) ->
  step fsm, i for i in inputs

src = ( file ) ->
  fs.readFileSync path.join(__dirname,
    "../fixtures/#{file}.fsm"), encoding : "utf8"

load = ( file ) -> jsFSM().load(src file)

module.exports =
  load : load
  src : src
  steps : steps
  step : step
