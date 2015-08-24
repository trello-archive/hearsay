uniqueKey = require './utils/uniqueKey'
ContinuousSignal = require './continuous-signal'

module.exports = class Slot extends ContinuousSignal
  constructor: (val) ->
    super (@_send) => @_send(val)
  set: (val) ->
    @_send(val)
    return val
  update: (fn) ->
    @set fn(@get())
