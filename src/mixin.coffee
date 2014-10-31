uniqueKey = require './uniqueKey'
watch = require './watch'

module.exports =
  watch: (target, path, callback) ->
    if arguments.length == 2
      callback = path
      path = target
      target = @

    observation = watch target, path, callback, this

    observationSet = (@_slot_observations ?= {})
    key = uniqueKey()
    observationSet[key] = observation

    return remove: ->
      observation.remove()
      delete observationSet[key]

  unwatch: ->
    for key, observation of @_slot_observations
      observation.remove()
    delete @_slot_observations
    return
