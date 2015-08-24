Signal = require '../signal'
ContinuousSignal = require '../continuous-signal'
all = require '../utils/all'

shallowClone = (array) -> array.slice()

isContinuous = (signal) -> signal instanceof ContinuousSignal

module.exports = (signals...) ->
  sent = new Array(signals.length)
  vals = new Array(signals.length)

  generator = (send) ->
    for signal, index in signals then do (signal, index) ->
      signal.subscribe (val) ->
        sent[index] = true
        vals[index] = val

        if all(sent)
          send(shallowClone vals)
    return

  if all(signals, isContinuous)
    new ContinuousSignal generator
  else
    new Signal generator
