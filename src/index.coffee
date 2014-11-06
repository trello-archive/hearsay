Signal = require './signal'

register = (target, map) ->
  for own name, method of map
    if name.indexOf('_') == 0
      throw new Error "You can't register methods that begin with an underscore!"
    if name of target
      throw new Error "#{name} is already defined!"
    target[name] = method
  return

registerMethods = (map) ->
  register(Signal.prototype, map)
registerFunctions = (map) ->
  register(Signal, map)

registerMethods
  map: require './combinators/map'
  filter: require './combinators/filter'
  latest: require './combinators/latest'
  distinct: require './combinators/distinct'
  changes: require './combinators/changes'
  and: require './combinators/and'
  or: require './combinators/or'
  not: require './combinators/not'

registerFunctions
  switch: require './combinators/switch'
  combine: require './combinators/combine'
  const: require './combinators/const'

module.exports =
  Signal: Signal
  ContinuousSignal: require './continuous-signal'
  Emitter: require './emitter'
  Slot: require './slot'
  watch: require './watch'
  mixin: require './mixin'
  registerMethods: registerMethods
  registerFunctions: registerMethods
