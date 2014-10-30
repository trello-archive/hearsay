uniqueIndex = 0
uniqueKey = -> String(uniqueIndex++)

class Slot
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
    return remove: ->
      delete watchers[key]

newObservation = (target, path, callback, context) ->
  remove = if path.length == 0
    throw new Error "No path!"
  else if path.length == 1
    finalObservation target, path[0], callback, context
  else
    intermediateObservation target, path, callback, context

  removed = false
  return remove: ->
    if removed
      throw new Error "Attempt to remove an observation more than once!"
    else
      remove()
    removed = true
    return

finalObservation = (target, key, callback, context) ->
  slot = target[key]
  remove = slot.watch callback, context
  return remove

intermediateObservation = (target, [head, tail...], callback, context) ->
  if tail.length == 0
    throw new Error "No tail!"

  next = { remove: -> }

  intermediateCallback = (val) ->
    next.remove()
    next = newObservation val, tail, callback, context
    return

  slot = target[head]
  remove = slot.watch intermediateCallback, context

  return ->
    remove()
    next.remove()
    return

watch = (target, path, callback, context) ->
  if typeof path == 'string'
    path = path.split '.'

  return newObservation target, path, callback, context

module.exports =
  watch: watch
  mixin:
    watch: (target, path, callback) ->
      if arguments.length == 2
        callback = path
        path = target
        target = @

      observation = watch target, path, callback, this

      observationSet = (@_slot_observations ?= {})
      key = uniqueKey()
      observationSet[key] = observation

      return remove: ->
        observation.remove()
        delete observationSet[key]

    unwatch: ->
      for key, observation of @_slot_observations
        observation.remove()
      delete @_slot_observations
      return
