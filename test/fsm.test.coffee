should = require("should")
assert = require("assert")
jsFSM = require '../index'
merge = require 'merge'

fsm = undefined

init = -> jsFSM
  initial : 'a'
  transitions : [
    {
      from : 'a'
      to : 'b'
      inputs : [ 'start', '!cancelled' ]
    }
    { from : 'b', to : 'd', inputs : [ 'toD' ] }
    { from : [ 'b', 'c' ], to : 'e', inputs : [ 'toE' ] }
  ]
  outputs :
    b : [ 'running', '!abc' ]
    '!b' : [ 'abc' ]

describe "fsm", ->

  beforeEach -> fsm = init()

  it "requires initial state", ( done ) ->
    (-> jsFSM()).should.throw
    done()

  it "can't transition to wildcard", ( done ) ->
    ( -> fsm
      initial : 'a'
      transitions : [
        { from : 'a', to : '*' }
      ]
    ).should.throw
    done()

  it "transition needs a 'to'", ( done ) ->
    ( -> fsm
      initial : 'a'
      transitions : [
        { from : 'a' }
      ]
    ).should.throw
    done()

  it "without the proper input, clock() is a no op", ( done ) ->
    fsm.current().should.equal 'a'
    fsm.resetStart()
    fsm.clock()
    fsm.current().should.equal 'a'
    done()

  it "clock() transitions with input", ( done ) ->
    fsm.current().should.equal 'a'
    fsm.start true
    fsm.clock()
    fsm.current().should.equal 'b'
    done()

  it "signals default to false", ( done ) ->
    fsm.running().should.equal false
    done()

  it "again, clock() is no op without proper inputs", ( done ) ->
    fsm.current().should.equal 'a'
    fsm.start true
    fsm.clock()
    fsm.current().should.equal 'b'
    fsm.clock()
    fsm.current().should.equal 'b'
    done()

  it "clock() with proper inputs", ( done ) ->
    fsm.current().should.equal 'a'
    fsm.set 'start'
    fsm.reset 'start'
    fsm.clock()
    fsm.current().should.equal 'a'
    fsm.set 'start'
    fsm.clock()
    fsm.current().should.equal 'b'
    fsm.toD true
    fsm.clock()
    fsm.current().should.equal 'd'
    done()

  describe 'persist', ->

    store = {}

    beforeEach ->
      fsm = init()

    it "stores state and signals in fsm.data", ( done ) ->
      fsm._data._current.should.exist

      fsm
      .setStart()
      .clock()
      .current().should.be.eql 'b'

      store = fsm.save()
      done()

    it "restore", ( done ) ->
      fsm
      .load store
      .current().should.eql 'b'
      done()

