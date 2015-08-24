Signal = require '../signal'
ContinuousSignal = require '../continuous-signal'

# If the outer signal is discrete, this produces a discrete signal. Always.
# If the outer signal is continuous, it will produce a continuous signal *if*
# the current value is a continuous signal.

# If the inner signal later becomes a discrete signal, it doesn't matter: the
# returned signal will still be continuous. This is potentially unexpected.

magicInitialValue = {}

isContinuous = (signal) -> signal instanceof ContinuousSignal

module.exports = ->
  outerSignal = this
  generator = (send) ->
    unsubscribe = magicInitialValue
    outerSignal.subscribe (innerSignal) ->
      if unsubscribe != magicInitialValue
        unsubscribe()

      unsubscribe = innerSignal.subscribe send

  if isContinuous(outerSignal) && isContinuous(outerSignal.get())
    outerSignal.derive generator
  else
    new Signal generator
