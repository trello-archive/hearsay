Signal = require '../signal'

magicInitialValue = {}

jsEq = (a, b) -> a == b

module.exports = (signal, eq = jsEq) ->
  prev = magicInitialValue
  signal.derive (send) ->
    signal.subscribe (val) ->
      if prev == magicInitialValue
        send val
      else if !eq(prev, val)
        send val
      prev = val
