uniqueKey = require './utils/uniqueKey'
watch = require './watch'
subscribeChanges = require './methods/subscribe-changes'

remember = (target, unsubscribe) ->
  observationSet = (target._hearsay_observations ?= {})
  key = uniqueKey()
  observationSet[key] = unsubscribe
  return ->
    unsubscribe()
    delete observationSet[key]

module.exports =
  subscribe: (signal, callback) ->
    remember this, signal.subscribe(callback, this)

  subscribeChanges: (signal, callbacks) ->
    remember this, subscribeChanges.call(signal, callbacks, this)

  watch: (target, path, callback) ->
    if arguments.length == 2
      callback = path
      path = target
      target = @

    remember this, watch(target, path, callback, this)

  unsubscribe: ->
    for key, unsubscribe of @_hearsay_observations
      unsubscribe()
    delete @_hearsay_observations
    return
