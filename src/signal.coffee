uniqueKey = require 'hearsay/uniqueKey'
once = require 'hearsay/once'

module.exports = class Signal
  constructor: (source) ->
    source @_send.bind(@)
    @_subscriptions = {}

  _send: (val) ->
    for key, [fn, context] of @_subscriptions
      fn.call context, val
    return

  subscribe: (fn, context) ->
    watchers = @_subscriptions
    key = uniqueKey()
    watchers[key] = [fn, context]

    return remove: once 'Already disposed!', ->
      delete watchers[key]
      return

  derive: (source) -> new Signal source
