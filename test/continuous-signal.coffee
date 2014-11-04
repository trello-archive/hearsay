ContinuousSignal = require 'hearsay/continuous-signal'
{ assert } = require 'chai'

class Subject
  constructor: (val) -> @signal = new ContinuousSignal val, (@send) =>

describe "ContinuousSignal", ->
  it "starts with its current value", ->
    subject = new Subject(1)
    signal = subject.signal

    vals = []
    subscription = signal.subscribe (val) ->
      vals.push val
    subscription.remove()
    assert.deepEqual vals, [1]

  it "sends to all subscribers", ->
    subject = new Subject(1)
    signal = subject.signal

    vals1 = []
    vals2 = []
    subscription1 = signal.subscribe (val) ->
      vals1.push val
    subscription2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10]

    subscription1.remove()
    subscription2.remove()

  it "doesn't send to a removed subscriber", ->
    subject = new Subject(1)
    signal = subject.signal

    vals1 = []
    vals2 = []
    subscription1 = signal.subscribe (val) ->
      vals1.push val
    subscription2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10]

    subscription1.remove()
    subject.send 20

    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10, 20]

    subscription2.remove()
