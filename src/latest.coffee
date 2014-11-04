Signal = require 'hearsay/signal'
ContinuousSignal = require 'hearsay/continuous-signal'

# If the outer signal is discrete, this produces a discrete signal. Always.
# If the outer signal is continuous, it will produce a continuous signal *if*
# the current value is a continuous signal.

# If the inner signal later becomes a discrete signal, it doesn't matter: the
# returned signal will still be continuous. This is potentially unexpected.

magicInitialValue = {}

isContinuous = (signal) -> signal instanceof ContinuousSignal

module.exports = (outerSignal) ->
  generator = (send) ->
    currentSubscription = magicInitialValue
    outerSignal.subscribe (innerSignal) ->
      if currentSubscription != magicInitialValue
        currentSubscription.remove()

      currentSubscription = innerSignal.subscribe send

  if isContinuous(outerSignal) && isContinuous(outerSignal.get())
    outerSignal.derive generator
  else
    new Signal generator
