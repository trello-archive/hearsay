uniqueKey = require './utils/uniqueKey'
watch = require './watch'
subscribeChanges = require './methods/subscribe-changes'

hasProp = (obj, prop) ->
  Object.hasOwnProperty.call(obj, prop)

remember = (target, unsubscribe) ->
  observationSet = (target._hearsay_subscriptions ?= {})
  key = uniqueKey()
  observationSet[key] = unsubscribe
  return ->
    unsubscribe()
    delete observationSet[key]

module.exports =
  subscribe: (signal, callback) ->
    remember this, signal.subscribe(callback, this)

  using: (signal) ->
    @_hearsay_using ?= []
    @_hearsay_using.push signal.use()
    signal

  subscribeChanges: (signal, callbacks) ->
    remember this, subscribeChanges.call(signal, callbacks, this)

  watch: (target, path, callback) ->
    if arguments.length == 2
      callback = path
      path = target
      target = this

    remember this, watch(target, path, callback, this)

  unsubscribe: ->
    if !hasProp(@, '_hearsay_subscriptions')
      return
    for key, unsubscribe of @_hearsay_subscriptions
      unsubscribe()
    delete @_hearsay_subscriptions
    return

  stopUsing: ->
    if !hasProp(@, '_hearsay_using')
      return
    for stopUsing in @_hearsay_using
      stopUsing()
    delete @_hearsay_using
    return
