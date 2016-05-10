fsm = require( '../../index' )
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
    '0, 5, 10, 15' : [ '!candy' ]
    '20, 25' : [ 'candy' ]
    '0, 5, 10, 15, 20' : [ '!FIVE' ]
    '25' : [ 'FIVE' ]

fsm.on "enter", ( from, to, desc ) ->
  console.log "#{from} -> #{to}, #{desc}" +
      "#{if @candy() then ', CANDY' else ''}" +
      "#{if @FIVE() then ', credit=5' else ''}"

insert = ( name ) ->
  fsm.dime false
  fsm.nickle false
  fsm[ name ] true
  fsm.clock()

insert 'nickle'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'nickle'

