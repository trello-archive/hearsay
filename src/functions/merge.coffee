Signal = require '../signal'

module.exports = (signals...) ->
  new Signal (send) ->
    for signal in signals
      signal.subscribe (val) ->
        send(val)
    return
