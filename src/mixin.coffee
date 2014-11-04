uniqueKey = require './uniqueKey'
watch = require './watch'

module.exports =
  watch: (target, path, callback) ->
    if arguments.length == 2
      callback = path
      path = target
      target = @

    observation = watch target, path, callback, this

    observationSet = (@_hearsay_observations ?= {})
    key = uniqueKey()
    observationSet[key] = observation

    return remove: ->
      observation.remove()
      delete observationSet[key]

  unwatch: ->
    for key, observation of @_hearsay_observations
      observation.remove()
    delete @_hearsay_observations
    return
