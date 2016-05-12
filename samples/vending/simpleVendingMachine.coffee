_ = require 'lodash'
fsm = require('../../index')
  initial : '0'
  transitions : [
    { from : [ '0', '20' ], to : '5', inputs : 'nickle' }
    { from : [ '0', '20' ], to : '10', inputs : 'dime' }
    { from : [ '5', '25' ], to : '10', inputs : 'nickle' }
    { from : [ '5', '25' ], to : '15', inputs : 'dime' }
    { from : '10', to : '15', inputs : 'nickle' }
    { from : '10', to : '20', inputs : 'dime' }
    { from : '15', to : '20', inputs : 'nickle' }
    { from : '15', to : '25', inputs : 'dime' }
  ]
  outputs :
    '^5,25' : [ 'light5' ]
    '^10' : [ 'light10' ]
    '^15' : [ 'light15' ]
    '^20, 25' : [ 'lightCandy' ]

width = 9

print = ( row, sep = '|' ) ->
  console.log (_.pad i, width for i in row).join sep

hr = ( cols ) ->
  row = (_.repeat '-', cols for i in [ 0..cols - 1 ])
  print row, '+'

x = ( v ) -> if v then 'x' else ' '
header = [ 'coin', 'from', 'to', '5', '10', '15', 'candy' ]

print header
hr header.length

fsm.on "state", ( current, from, desc ) ->
  row = [ desc, from, current,  x(@light5()), x(@light10()),
    x(@light15()), x(@lightCandy()) ]
  print row
  hr header.length

coins = [ 'nickle', 'dime' ]
for c in coins
  do( c ) ->
    others = _.without coins, c
    fsm.on "changed:#{c}", ( v ) ->
      fsm.reset o for o in others if v

insert = ( name ) ->
  fsm.set(name).clock()

insert 'nickle'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'nickle'

