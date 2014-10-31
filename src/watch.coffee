newObservation = (target, path, callback, context) ->
  if path.length == 0
    throw new Error "No path!"

  remove = if path.length == 1
    finalObservation target, path[0], callback, context
  else
    intermediateObservation target, path, callback, context

  removed = false
  return remove: ->
    if removed
      throw new Error "Observation already removed!"
    else
      remove()
    removed = true
    return

finalObservation = (target, key, callback, context) ->
  slot = target[key]
  { remove } = slot.watch callback, context
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
  { remove } = slot.watch intermediateCallback, context

  return ->
    remove()
    next.remove()
    return

module.exports = (target, path, callback, context) ->
  if typeof path == 'string'
    path = path.split '.'

  return newObservation target, path, callback, context
