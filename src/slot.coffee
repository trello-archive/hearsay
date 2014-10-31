uniqueKey = require './uniqueKey'

module.exports = class Slot
  constructor: (@val) ->
    @_watchers = {}

  get: -> @val
  set: (val) ->
    @val = val
    @_trigger()
    return val

  _trigger: ->
    for key, [fn, context] of @_watchers
      fn.call context, @val
    return

  watch: (fn, context) ->
    fn.call context, @val
    watchers = @_watchers
    key = uniqueKey()
    watchers[key] = [fn, context]
    removed = false
    return remove: ->
      if removed
        throw new Error "Observation already removed!"
      delete watchers[key]
      removed = true
      return
