Signal = require '../signal'

magicInitialValue = {}

module.exports = ->
  signal = this
  previousValue = magicInitialValue
  new Signal (send) ->
    signal.subscribe (val) ->
      if previousValue != magicInitialValue
        send [previousValue, val]
      previousValue = val
