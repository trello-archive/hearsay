Signal = require '../signal'
ContinuousSignal = require '../continuous-signal'

shallowClone = (array) -> array.slice()

isContinuous = (signal) -> signal instanceof ContinuousSignal

all = (list, pred = (a) -> a) ->
  for x in list
    if !pred(x)
      return false
  return true

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
    # TODO...
    ContinuousSignal::derive generator
  else
    new Signal generator
