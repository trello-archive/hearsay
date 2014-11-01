# This implementation appears more complex than it needs to be be, but this is
# because it is not trivial to support observing cyclic structures in a robust
# way. If you're thinking "I could rewrite this in half the code," ask yourself
# if your simpler solution would handle that case. If so, please file a pull
# request!

# I opted to solve the cyclic problem by attaching to each callback a predicate
# that asks each observation "to the left of it" if it is watching the same slot
# already. If so, it simply doesn't fire.

# `allowFirst` exists to distinguish between the initial callback invocation
# (since `slot.watch` calls the callback immediately) and subsequent invocations
# by `slot.set`. We only want to guard the latter case, or else the observation
# stack won't be set up correctly.

guarded = (fn, pred) ->
  ->
    if pred()
      fn.apply(this, arguments)
    return

allowFirst = (pred) ->
  first = true
  ->
    if first
      first = false
      return true
    else
      pred()

newObservation = (target, path, callback, context, pred) ->
  if path.length == 0
    throw new Error "No path!"

  remove = if path.length == 1
    finalObservation target, path[0], callback, context, pred
  else
    intermediateObservation target, path, callback, context, pred

  removed = false
  return remove: ->
    if removed
      throw new Error "Observation already removed!"
    else
      remove()
    removed = true
    return

finalObservation = (target, key, callback, context, pred) ->
  slot = target[key]

  guardedCallback = guarded callback, allowFirst -> pred slot

  { remove } = slot.watch guardedCallback, context
  return remove

intermediateObservation = (target, [head, tail...], callback, context, pred) ->
  if tail.length == 0
    throw new Error "No tail!"

  next = { remove: -> }
  slot = target[head]

  intermediateCallback = (val) ->
    next.remove()
    next = newObservation val, tail, callback, context, (otherSlot) ->
      slot != otherSlot && pred(otherSlot)
    return

  guardedCallback = guarded intermediateCallback, allowFirst -> pred slot

  { remove } = slot.watch guardedCallback, context

  return ->
    remove()
    next.remove()
    return

module.exports = (target, path, callback, context) ->
  if typeof path == 'string'
    path = path.split '.'

  return newObservation target, path, callback, context, -> true
