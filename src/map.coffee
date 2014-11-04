module.exports = (signal, fn) ->
  signal.derive (send) ->
    signal.subscribe (val) ->
      send fn(val)
