# js-fsm
## Moore Finite State Machine (FSM)
[![Build Status](https://travis-ci.org/venkatperi/js-fsm.svg?branch=master)](https://travis-ci.org/venkatperi/js-fsm)

`js-fsm` is a simple javascript Moore Finite State Machine. To use it, define
* the starting state,
* transitions (from state, to state, and inputs)
* outputs at each state.

Set your inputs and call `fsm.clock()`.

## Installation

Install with npm

```shell
npm install prop-it
```

## Example
### Simple Vending Machine

A vending machine dispenses pieces of candy that cost 20 cents each. The machine accepts nickels and dimes only and does not give change. As soon as the amount deposited equals or exceeds 20 cents, the machine releases a piece of candy. The next coin deposited starts the process over again.


Our state machine has states for the each possible deposited amount: 0 for zero cents deposited, 5 cents, 10 cents, 15 cents, 20 cents and 25 cents.


#### Defining the FSM
```
fsm = require( 'js-fsm' )
  initial : '0'	# zero cents deposited

  transitions : [
    { from : [ '0', '20' ], to : '5', inputs : [ 'nickle' ] }
    { from : [ '0', '20' ], to : '10', inputs : [ 'dime' ] }
    { from : [ '5', '25' ], to : '10', inputs : [ 'nickle' ] }
    { from : [ '5', '25' ], to : '15', inputs : [ 'dime' ] }
    { from : '10', to : '15', inputs : [ 'nickle' ] }
    { from : '10', to : '20', inputs : [ 'dime' ] }
    { from : '15', to : '20', inputs : [ 'nickle' ] }
    { from : '15', to : '25', inputs : [ 'dime' ] }
  ]
  
  outputs :
    '0, 5, 10, 15' : [ '!candy' ]
    '20, 25' : [ 'candy' ]
    '0, 5, 10, 15, 20' : [ '!FIVE' ]
    '25' : [ 'FIVE' ]	# the user has credit
```

#### Operating the vending machine

```coffeescript
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

###
0 -> 5, #nickle
5 -> 15, #dime
15 -> 25, #dime, CANDY, credit=5
25 -> 15, #dime
15 -> 25, #dime, CANDY, credit=5
25 -> 15, #dime
15 -> 20, #nickle, CANDY
###
```


