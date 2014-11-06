ContinuousSignal = require '../continuous-signal'

module.exports = (val) ->
  new ContinuousSignal val, (send) ->
