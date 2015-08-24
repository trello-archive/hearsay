Signal = require './signal'

magicInitialValue = {}

module.exports = class ContinuousSignal extends Signal
  constructor: (source) ->
    @_val = magicInitialValue
    super (actuallySend) =>
      source (val) =>
        @_val = val
        actuallySend val
    if @_val == magicInitialValue
      throw new Error "The callback passed to ContinuousSignal must synchronously invoke its send function!"
  get: -> @_val
  subscribe: (fn, context) ->
    fn.call context, @get()
    super

  derivedType: ContinuousSignal
