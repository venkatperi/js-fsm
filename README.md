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

## API

### Methods

#### fsm(options)

`options` is an `{Object}`

* **initial** is a `{String}` with the initial state name.

* **transitions** is an `{Array}` of `{Object}`s that specify the destination state and necessary inputs for each transition

  * **from** `{String}` is the current state
  * **to** `{String}` is the destination of the transition
  * **inputs** is an `{Array}` of signal names and their required state. A transition is possible only if all inputs are true. A `signal` prefixed with a `!` is negated and so is true if it is low (false) and vice-versa.
```coffeescript
# This transition will occur only when start is true and cancelled is false
{ from: 'initial', to: 'type', inputs: ['start', '!cancelled']
```

* **outputs** `{Object}` specifies which signals  are to be set (and their value) depending on the current state.

```coffeescript
# signal candy will go high only in states 20 and 25 and is low everywhere else
# FIVE will go high only in state 25 and is low everywhere else

outputs :
  '0, 5, 10, 15' : [ '!candy' ]
  '20, 25' : [ 'candy' ]
  '0, 5, 10, 15, 20' : [ '!FIVE' ]
  '25' : [ 'FIVE' ]
```

#### fsm.signal([value])

Gets or sets the value of the named signal (signal must be replaced with the appropriate name above).

```coffeescript
#set signal nickle to true and dime to false
fsm
.nickle true
.dime false
```

#### fsm.clock()

Instructs the FSM to attempt a transition based on the current input values. If no transition is possible, the fsm will emit a `noop` event. 

```coffeescript
# sets input values and and transitions (if possible)
fsm
.dime false
.nickle true
.clock()
```

### Events 

#### on('noop', cb())

`fsm.clock()` resulted in no state change.

#### on('leave', cb(from, to, desc))

#### on('enter', cb(from, to, desc))

Fired when the FSM leaves / enters a state. The callback **cb** receives the state names **from**, **to** and a string description of why the transition occured.

