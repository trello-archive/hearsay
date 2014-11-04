Signal = require './signal'

magicInitialValue = {}

module.exports = class ContinuousSignal extends Signal
  constructor: (@_val, source) ->
    super (actuallySend) =>
      source (val) =>
        @_val = val
        actuallySend val
    if @_val == magicInitialValue
      throw new Error "Derived signals must subscribe to their underlying signal!"
  get: -> @_val
  subscribe: (fn, context) ->
    fn.call context, @get()
    super

  derive: (source) -> new ContinuousSignal magicInitialValue, source
