Signal = require '../signal'

module.exports = (signals...) ->
  new Signal (send) ->
    subscriptions = signals.map (signal) ->
      signal.subscribe(send)
    return ->
      subscriptions.forEach (unsubscribe) ->
        unsubscribe()
