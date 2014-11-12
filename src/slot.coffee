uniqueKey = require './utils/uniqueKey'
ContinuousSignal = require './continuous-signal'

module.exports = class Slot extends ContinuousSignal
  constructor: (val) ->
    super val, (@_send) =>
  set: (val) ->
    @_send(val)
    return val
  update: (fn) ->
    @set fn(@get())
