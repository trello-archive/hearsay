module.exports = (signal, fn) ->
  new Signal (send) ->
    signal.subscribe (val) ->
      send fn(val)
