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
    '20, 25' : [ 'candy' ]
    '!20, 25' : [ '!candy' ]
    '!25' : [ '!FIVE' ]
    '25' : [ 'FIVE' ]

fsm.on "state", ( current, from, desc ) ->
  console.log "#{from} -> #{current}, #{desc}" +
      "#{if @candy() then ', CANDY' else ''}" +
      "#{if @FIVE() then ', credit=5' else ''}"

insert = ( name ) ->
  fsm
  .reset 'dime', 'nickle'
  .set name
  .clock()

insert 'nickle'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'dime'
insert 'nickle'

