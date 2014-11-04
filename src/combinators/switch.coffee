Signal = require '../signal'
ContinuousSignal = require '../continuous-signal'
map = require './map'
latest = require './latest'
distinct = require './distinct'

# ...this will return a continuous or a discrete signal in different contexts

module.exports = (pred, first, second) ->
  chosenSignal = map.call distinct.call(pred), (input) ->
    if input then first else second
  latest.call chosenSignal
