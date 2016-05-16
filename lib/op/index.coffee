flatten = require 'flatten'

output = ( x ) -> input(x).output()

normalize = ( name ) ->
  name = name.trim()
  return [ name[ 1.. ].trim(), 'not' ] if name[ 0 ] is '!'
  [ name ]

input = ( target, node ) ->
  return target if target.output?
  return new Literal target if arguments.length < 2
  name = node.id?.name or node
  ref = new Read target, name
  return ref unless node.invert
  new Wrap(new Not ref)

### !pragma coverage-skip-next ###
class Op
  desc : -> ""
  output : ->

class Literal extends Op
  constructor : ( value ) -> @value = Boolean value
  ### !pragma coverage-skip-next ###
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
    ### !pragma coverage-skip-next ###
    if typeof x is 'function' then x(v) else @target[ @name ] = v
    v
  ### !pragma coverage-skip-next ###
  desc : => @input.desc()
  output : => @write @input.output()

class Not extends Op
  constructor : ( i ) -> @input = input i
  desc : => "not(#{@input.desc()})"
  output : => !@input.output()

class Multi extends Op
  constructor : ( inputs... ) ->
    @inputs = (input i for i in flatten inputs)
  _join : ( x ) => (i.desc() for i in @inputs).join x
  _output : ( fn, initial ) => @inputs.reduce ( ( a, b ) ->
    fn output(a), output(b)), initial

class Or extends Multi
  ### !pragma coverage-skip-next ###
  desc : => @_join ' or '
  output : => @_output (( a, b ) -> a or b), false

class And extends Multi
  desc : => @_join ' and '
  output : => @_output (( a, b ) -> a and b), true

module.exports = op =
  normalize : normalize
  input : input
  not : ( i ) -> new Not i
  and : ( inputs... ) -> new And inputs
  or : ( inputs... ) -> new Or inputs
  write : ( input, target, name ) -> new Write input, target, name
      
