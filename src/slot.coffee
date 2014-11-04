uniqueKey = require 'hearsay/uniqueKey'
ContinuousSignal = require 'hearsay/continuous-signal'

module.exports = class Slot extends ContinuousSignal
  constructor: (val) ->
    super val, (@_send) =>
  set: (val) ->
    @_send(val)
    return val
