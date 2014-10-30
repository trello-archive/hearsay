mixin Backbone.Events, class Slot
  constructor: (@val) ->
  set: (val) ->
    oldVal = @val
    @val = val
    @trigger 'change', val, oldVal
    return val
  get: -> @val

uniqueIndex = 0
uniqueKey = -> String(uniqueIndex++)

newObservation = (target, path, callback, context) ->
  remove = if path.length == 0
    throw new Error("No path!")
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
  slot.on 'change', callback, context
  callback.call context, slot.get()
  return ->
    slot.off 'change', callback, context
    return

intermediateObservation = (target, [head, tail...], callback) ->
  if tail.length == 0
    throw new Error("No tail!")

  next = null

  makeNext = (current) ->
    next = newObservation(current, tail, callback, context)
    return

  intermediateCallback = (current) ->
    next.remove()
    makeNext(current)
    return

  slot = target[head]
  slot.on 'change', intermediateCallback
  makeNext slot.get()

  return ->
    slot.off 'change', intermediateCallback
    next.remove()
    return

watch = (target, path, callback) ->
  if typeof path == 'string'
    path = path.split('.')

  return newObservation(target, path, callback)

module.exports =
  watch: watch
  mixin:
    watch: (target, path, callback) ->
      if arguments.length == 2
        callback = path
        path = target
        target = @

      observation = watch target, path, callback

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
