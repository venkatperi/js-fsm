flatten = require 'flatten'

normalize = ( name ) ->
  name = name.trim()
  unary = undefined
  if name[ 0 ] is '!'
    unary = 'not'
    name = name[ 1.. ].trim()
  out = [ name ]
  out.push unary if unary?
  out

input = ( target, name ) ->
  return target if target.output?
  if arguments.length is 2
    [name, unary] = normalize name
    ref = new Read target, name
    return if unary then new Wrap( new op[ unary ] ref ) else ref
  new Literal target

class Op
  desc : ->

class Literal extends Op
  constructor : ( value ) -> @value = Boolean value
  desc : => "#{if @value then 'true' else 'false'}"
  output : => @value

class Wrap extends Op
  constructor : ( other ) -> @other = input other
  desc : => "(#{@other.desc()})"
  output : => @other.output()

class Read extends Op
  constructor : ( @target, @name ) ->
  read : =>
    x = @target[ @name ]
    if typeof x is 'function' then x() else x
  desc : => "##{@name}"
  output : => @read()

class Write extends Op
  constructor : ( @input, @target, @name ) ->
  write : ( v ) =>
    x = @target[ @name ]
    if typeof x is 'function' then x( v ) else @target[ @name ] = v
    v
  desc : => @input.desc()
  output : => @write @input.output()

class Not extends Op
  constructor : ( i ) -> @input = input i
  desc : => "not(#{@input.desc()})"
  output : => !@input.output()

class Multi extends Op
  constructor : ( inputs... ) ->
    inputs = flatten inputs
    @inputs = []
    @inputs.push input i for i in inputs

class Or extends Multi
  desc : => (i.desc() for i in @inputs).join ' or '
  output : => @inputs.reduce ( ( a, b ) ->
    input( a ).output() or input( b ).output()), false

class And extends Multi
  desc : => (i.desc() for i in @inputs).join ' and '
  output : => @inputs.reduce ( ( a, b ) ->
    input( a ).output() and b.output()), true

module.exports = op =
  normalize : normalize
  input : input
  not : ( i ) -> new Not i
  and : ( inputs... ) -> new And inputs
  or : ( inputs... ) -> new Or inputs
  write : ( input, target, name ) -> new Write input, target, name
      
