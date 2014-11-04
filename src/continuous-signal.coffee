Signal = require './signal'

module.exports = class ContinuousSignal extends Signal
  constructor: (@val, generator) ->
    super (actuallySend) =>
      generator (val) =>
        @val = val
        actuallySend val
  get: -> @val
  subscribe: (fn, context) ->
    fn.call context, @get()
    super
