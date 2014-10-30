# Mixing in `Slots` to any Backbone.Events gives you two methods: watch and
# unwatch.
#
# It will also include some private helpers to maintain state, all of which
# are prefixed with `_slot_`.
#
# Depends on underscore.js, as Backbone does. This is trivially fixed, though.
# It only uses one function.
#
# Note! Like Backbone, it *will* mutate objects that you observe, by attaching
# the `_slot_key` key, which will be a string.

# There's no support for keys with periods in them. You just can't observe
# them. There is currently no plan for supporting them either, until we can
# use ES6's Map type.
#
# There's really no reason for this to depend on Backbone... all it uses
# is `on` and `off`. I can just write those out myself.

mixin Backbone.Events, class Slot
  constructor: (@val) ->
  set: (val) ->
    oldVal = @val
    @val = val
    @trigger 'change', val, oldVal
    return val
  get: -> @val

Slots = do ->
  uniqueIndex = 0

  keyFor = (obj) ->
    obj._slot_key ?= String(uniqueIndex++)

  newObservation = (target, path, callback, context) ->
    if path.length == 0
      throw new Error("No path!")
    else if path.length == 1
      finalObservation(target, path[0], callback, context)
    else
      intermediateObservation(target, path, callback, context)

  finalObservation = (target, key, callback, context) ->
    slot = target[key]
    slot.on 'change', callback, context
    callback.call(context, slot.get())
    return remove: ->
      slot.off 'change', callback, context
      return

  intermediateObservation = (target, [head, tail...], callback) ->
    if tail.length == 0
      throw new Error("No tail!")

    next = null

    makeNext = (current) ->
      next = newObservation(current, tail, callback, context)
      return

    intermediateCallback = (current) ->
      next.remove()
      makeNext(current)
      return

    slot = target[head]
    slot.on 'change', intermediateCallback
    makeNext slot.get()

    return remove: ->
      slot.off 'change', intermediateCallback
      next.remove()
      return

  # Usage:
  #
  #     this.watch(target, 'foo.bar.baz', callback)
  #
  # Adds a nested watcher. `callback` is always invoked with
  # `this` as the context, as in `listenTo`.
  #
  # There is one overload:
  #
  # this.watch('foo.bar.baz', callback) = this.watch(this, 'foo.bar.baz', callback)
  #
  # Similar to listenTo, but only works with
  # slots' change events, and allows nesting.
  #
  # The following two lines are equivalent:
  #
  #     this.watch(target, 'foo', callback)
  #     this.listenTo(target.foo, 'change', callback)
  #
  # You have to do some kind of work to clean up afterwards.
  # More details to come.
  #
  # Terminology: "event emitter" means "any object with Backbone.Events mixed
  # in"
  #
  # `target` must be an event emitter
  # `path` must refer to Slots that hold event emitters each step
  # of the way.
  #
  # If path refers to a backbone model, too bad.
  # That won't work.
  # Though it would be pretty easy to make this work. If you wanted to.
  #
  watch: (target, pathString, callback) ->
    if arguments.length == 2
      callback = pathString
      pathString = target
      target = @

    observation = newObservation(target, path.split('.'), callback)

    @_targets ?= {}
    targetMap = (@_targets[keyFor target] ?= {})
    observations = (targetMap[pathString] ?= [])
    observations.push [callback, observation]
    return

  # Like stopListening, there are multiple overloads:
  #
  #     this.unwatch()
  #     this.unwatch(target)
  #     this.unwatch('foo.bar') = this.unwatch(this, 'foo.bar')
  #     this.unwatch(target, 'foo.bar')
  #     this.unwatch('foo.bar', callback) = this.unwatch(this, 'foo.bar', callback)
  #     this.unwatch(target, 'foo.bar', callback)
  #
  # It does what you'd expect.
  #
  # It only unwatches things that were explicitly watched with .watch.
  # What I mean by that is that the following `unwatch` doesn't do anything:
  #
  #     this.watch(foo, 'bar.baz', callback)
  #     this.unwatch(foo.bar.get(), 'baz')
  #
  # Because that wouldn't really make sense.
  #
  unwatch: ->
    if typeof arguments[0] == 'string'
      return @unwatch this, arguments...

    switch arguments.length
      when 0
        @_unwatchEverything()
      when 1
        [target] = args
        @_unwatchTarget arg
      when 2
        [target, pathString] = arguments
        @_unwatchPath target, pathString
      when 3
        [target, pathString, callback] = arguments
        @_unwatch target, pathString, callback

    return

  _unwatchEverything: ->
    if !@_targets? then return

    for targetKey, pathMap of @_targets
      for pathString, list of pathMap
        for [callback, observation] in list
          observation.remove()

    delete @_targets
    return

  _unwatchTarget: (target) ->
    targetMap = @_targets[keyFor target]
    if !targetMap? then return

    for pathString, list of targetMap
      for [callback, observation] in list
        observation.remove()

    delete @_targets[keyFor target]
    return

  _unwatchPath: (target, pathString) ->
    targetMap = @_targets[keyFor target]
    if !targetMap? then return

    list = targetMap[pathString]
    if !list? then return

    for [callback, observation] in list
      observation.remove()

    delete targetMap[pathString]
    return

  _unwatch: (target, [head, tail...], callback) ->
    targetMap = @_targets[keyFor target]
    if !targetMap? then return

    list = targetMap[pathString]
    if !list? then return

    newList = []

    for [sourceCallback, observation] in list
      if sourceCallback == callback
        observation.remove()
      else
        newList.push [sourceCallback, observation]

    if newList.length == 0
      delete targetMap[pathString]
    else
      targetMap[pathString] = newList
    return
