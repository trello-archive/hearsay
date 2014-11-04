Signal = require '../signal'

module.exports = (pred) ->
  signal = this
  new Signal (send) ->
    signal.subscribe (val) ->
      if pred val
        send val
