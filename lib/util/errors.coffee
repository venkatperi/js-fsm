TypedError = require 'error/typed'
_ = require 'lodash'

MissingInfoError = TypedError
  type : 'missingInfo'
  message : "The following information is missing: {name}."
  name : undefined

MissingOptionError = TypedError
  type : 'missingOption'
  message : "Missing option: {name}."
  name : undefined

ItemExistsError = TypedError
  type : 'itemExists'
  message : "The {type} '{name}' already exists."
  itemType : undefined
  name : undefined

InvalidOperationError = TypedError
  type : 'invalidOperation'
  message : "Invalid operation: {details}."
  details : undefined

NotPermittedError = TypedError
  type : 'notPermitted'
  message : "Not permitted: {details}."
  details : undefined

Throw = ( what ) ->
  it : -> throw what
  if : ( x ) -> throw what if x
  unless : ( x )  -> throw what unless x

module.exports =
  Throw : Throw
  MissingInfoError : MissingInfoError
  MissingOptionError : MissingOptionError
  ItemExistsError : ItemExistsError
  InvalidOperationError : InvalidOperationError
  NotPermittedError : NotPermittedError
