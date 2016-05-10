FSM = require './lib/FSM'

fsm = ( opts ) ->
  new FSM opts

fsm.FSM = FSM

module.exports = fsm