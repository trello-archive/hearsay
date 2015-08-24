Signal = require './signal'
schedulerRef = require './scheduler-ref'

register = (target, map) ->
  for own name, method of map
    if name.indexOf('_') == 0
      throw new Error "You can't register methods that begin with an underscore!"
    if name of target
      throw new Error "#{name} is already defined!"
    target[name] = method
  return

Hearsay =
  Signal: Signal
  ContinuousSignal: require './continuous-signal'
  Emitter: require './emitter'
  Slot: require './slot'
  watch: require './watch'
  mixin: require './mixin'
  setScheduler: (scheduler) ->
    schedulerRef.schedule = scheduler
  registerMethods: (map) ->
    register(Signal.prototype, map)
  registerFunctions: (map) ->
    register(Hearsay, map)

Hearsay.registerMethods
  map: require './methods/map'
  filter: require './methods/filter'
  latest: require './methods/latest'
  distinct: require './methods/distinct'
  changes: require './methods/changes'
  and: require './methods/and'
  or: require './methods/or'
  not: require './methods/not'
  spread: require './methods/spread'
  subscribeChanges: require './methods/subscribe-changes'

Hearsay.registerFunctions
  if: require './functions/if'
  combine: require './functions/combine'
  const: require './functions/const'
  merge: require './functions/merge'

module.exports = Hearsay
