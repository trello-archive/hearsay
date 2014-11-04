Signal = require '../signal'

magicInitialValue = {}

jsEq = (a, b) -> a == b

module.exports = (eq = jsEq) ->
  signal = this
  prev = magicInitialValue
  signal.derive (send) ->
    signal.subscribe (val) ->
      if prev == magicInitialValue
        send val
      else if !eq(prev, val)
        send val
      prev = val
