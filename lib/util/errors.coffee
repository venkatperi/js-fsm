TypedError = require 'error/typed'
_ = require 'lodash'

# istanbul ignore next
MissingInfoError = TypedError
  type : 'missingInfo'
  message : "The following information is missing: {name}."
  name : undefined

# istanbul ignore next
MissingOptionError = TypedError
  type : 'missingOption'
  message : "Missing option: {name}."
  name : undefined

# istanbul ignore next
ItemExistsError = TypedError
  type : 'itemExists'
  message : "The {type} '{name}' already exists."
  itemType : undefined
  name : undefined

# istanbul ignore next
InvalidOperationError = TypedError
  type : 'invalidOperation'
  message : "Invalid operation: {details}."
  details : undefined

# istanbul ignore next
NotPermittedError = TypedError
  type : 'notPermitted'
  message : "Not permitted: {details}."
  details : undefined

# istanbul ignore next
module.exports =
  MissingInfoError : MissingInfoError
  MissingOptionError : MissingOptionError
  ItemExistsError : ItemExistsError
  InvalidOperationError : InvalidOperationError
  NotPermittedError : NotPermittedError
