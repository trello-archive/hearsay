module.exports = (fn) ->
  signal = this
  signal.derive (send) ->
    signal.subscribe (val) ->
      send fn.apply(this, val)
