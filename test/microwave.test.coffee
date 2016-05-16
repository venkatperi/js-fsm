should = require("should")
assert = require("assert")
jsFSM = require '../index'
{load, steps} = require './ext/util'

fsm = undefined

sim = [
  { i : { open : true }, s : 'accessing', o : { lamp : true } }
  { i : { open : false }, s : 'idle', o : { lamp : false } }
  {
    i : { start : true },
    s : 'cooking',
    o : { lamp : false, turntable : true }
  }
  {
    i : { open : true },
    s : 'interrupted',
    o : { lamp : true, turntable : false }
  }
  {
    i : { open : false },
    s : 'cooking',
    o : { lamp : false, turntable : true }
  }
  {
    i : { done : true },
    s : 'completed',
    o : { lamp : false, turntable : false, beep : true }
  }
  {
    i : { open : true },
    s : 'accessing',
    o : { lamp : true, turntable : false }
  }
  {
    i : { open : false },
    s : 'idle',
    o : { lamp : false, turntable : false, beep : false }
  }
]

describe "microwave fsm", ->

  beforeEach -> fsm = load 'microwave'

  it "initial state is idle", ( done ) ->
    fsm.current().should.equal 'idle'
    fsm.lamp().should.equal false
    fsm.turntable().should.equal false
    fsm.beep().should.equal false
    done()

  it "step through", ( done ) ->
    steps fsm, sim
    done()

