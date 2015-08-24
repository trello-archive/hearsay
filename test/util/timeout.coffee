currentTimeout = null
callbackQueue = []

module.exports = (f) ->
  callbackQueue.push(f)
  if currentTimeout?
    return
  currentTimeout = setTimeout ->
    currentTimeout = null
    callbacks = callbackQueue
    callbackQueue = []
    for callback in callbacks
      callback()
    return
