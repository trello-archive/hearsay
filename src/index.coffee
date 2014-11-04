Signal = require './signal'

register = (map) ->
  proto = Signal.prototype
  for own name, method of map
    if name.indexOf('_') == 0
      throw new Error "You can't register methods that begin with an underscore!"
    if name of proto
      throw new Error "#{name} is already defined!"
    proto[name] = method
  return

register
  map: require './combinators/map'
  filter: require './combinators/filter'
  latest: require './combinators/latest'
  distinct: require './combinators/distinct'
  changes: require './combinators/changes'

module.exports =
  Signal: Signal
  ContinuousSignal: require './continuous-signal'
  Emitter: require './emitter'
  Slot: require './slot'
  watch: require './watch'
  mixin: require './mixin'
  register: register
