uniqueKey = require './utils/uniqueKey'
once = require './utils/once'
schedulerRef = require './scheduler-ref'

eligibleSignals = []
isDisposalScheduled = false

dispose = ->
  isDisposalScheduled = false
  signals = eligibleSignals
  eligibleSignals = []
  for signal in signals
    signal._scheduled = false
  for signal in signals when signal._users == 0
    signal._dispose()
  return

module.exports = class Signal
  _users: 0
  _disposed: false
  _scheduled: false

  constructor: (source) ->
    @_disposers = [source @_send.bind(@)]
    @_subscriptions = {}
    @_schedule()

  _send: (val) ->
    if @_disposed
      throw new Error("Signal cannot send events after disposal. (Did you forget to return a disposer?)")
    for key, [fn, context] of @_subscriptions
      fn.call context, val
    return

  _schedule: ->
    if @_scheduled
      return
    @_scheduled = true
    eligibleSignals.push(@)
    if isDisposalScheduled
      return
    schedulerRef.schedule(dispose)
    isDisposalScheduled = true
    return

  _dispose: ->
    @_disposed = true
    for disposer in @_disposers when typeof disposer != 'undefined'
      disposer()
    return

  subscribe: (fn, context) ->
    watchers = @_subscriptions
    key = uniqueKey()
    watchers[key] = [fn, context]
    unuse = @use()

    return once 'Cannot "unsubscribe" more than once!', ->
      delete watchers[key]
      unuse()
      return

  use: ->
    if @_disposed
      throw new Error("Cannot use a signal after it has been disposed.")
    @_users++
    return once 'Cannot "unuse" more than once!', =>
      @_users--
      if @_users == 0
        @_schedule()
      return

  derive: (source) ->
    unuse = @use()
    new @derivedType (send) ->
      disposeInner = source(send)
      return ->
        disposeInner()
        unuse()

  addDisposer: (disposer) ->
    if @_disposed
      throw new Error("Cannot add a disposer to a disposed signal.")
    @_disposers.push(disposer)
    return @

  derivedType: Signal
