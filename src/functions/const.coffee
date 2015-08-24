ContinuousSignal = require '../continuous-signal'

module.exports = (val) ->
  new ContinuousSignal (send) ->
    send(val)
    return
