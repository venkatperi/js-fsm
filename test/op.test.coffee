should = require( "should" )
assert = require( "assert" )
op = require '../lib/op'

obj = a = b = notA = undefined

describe "OP", ->

  beforeEach ->
    obj =
      a : true
      b : false
    a = op.input obj, 'a'
    b = op.input obj, 'b'
    notA = op.input obj, ' ! a'

  it "input", ( done ) ->
    a.output().should.equal true
    b.output().should.equal false
    notA.output().should.equal !a.output()
    done()

  it "not", ( done ) ->
    op.not( a ).output().should.equal !a.output()
    op.not( notA ).output().should.equal a.output()
    op.not( b ).output().should.equal !b.output()
    done()

  it "and", ( done ) ->
    x = op.and( a, b )
#    console.log x.desc()
    op.and( a, b ).output().should.equal false
    op.and( a, a, a, a ).output().should.equal true
    op.and( a, a, b, a, a ).output().should.equal false
    done()

  it "or", ( done ) ->
    op.or( a, b ).output().should.equal true
    op.or( b, b, b, b ).output().should.equal false
    done()

