should = require( "should" )
assert = require( "assert" )
jsFSM = require '../index'

fsm = undefined

describe "fsm", ->

  beforeEach ->
    fsm = jsFSM
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

  it "without the proper input, clock() is a no op", ( done ) ->
    fsm.current().should.equal 'a'
    fsm.start false
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
    fsm.on "noop", -> console.log "noop"
    fsm.current().should.equal 'a'
    fsm.start true
    fsm.clock()
    fsm.current().should.equal 'b'
    fsm.clock()
    fsm.current().should.equal 'b'
    done()

  it "clock() with proper inputs", ( done ) ->
    fsm.on "enter", (from, to, desc) -> console.log "#{from} -> #{to}, #{desc}"

    fsm.current().should.equal 'a'
    fsm.start true
    fsm.clock()
    fsm.current().should.equal 'b'
    fsm.toD true
    fsm.clock()
    fsm.current().should.equal 'd'
    done()

