Signal = require '../signal'
ContinuousSignal = require '../continuous-signal'
all = require '../utils/all'

isContinuous = (signal) -> signal instanceof ContinuousSignal

module.exports = (signals...) ->
  generator = (send) ->
    for signal in signals
      signal.subscribe (val) ->
        send(val)
    return

  if all(signals, isContinuous)
    ContinuousSignal::derive generator
  else
    new Signal generator
