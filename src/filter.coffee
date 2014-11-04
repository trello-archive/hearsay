Signal = require 'hearsay/signal'

module.exports = (signal, pred) ->
  new Signal (send) ->
    signal.subscribe (val) ->
      if pred val
        send val
