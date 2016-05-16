should = require("should")
assert = require("assert")
jsFSM = require '../index'
{steps, step, load} = require './ext/util'

fsm = undefined

sim = [
  { i : { input1 : true }, s : 'state2', o : { output2 : false } }
  { i : { input2 : true }, s : 'state3', o : { output3 : true } }
  { i : { input3 : true }, s : 'state1', o : { output1 : true } }
]

describe "simple fsm", ->

  beforeEach -> fsm = load 'simple'

  it "initial state", ( done ) ->
    fsm.current().should.equal 'state1'
    fsm.output1().should.equal true
    done()

  it "step through", ( done ) ->
    steps fsm, sim
    done()


