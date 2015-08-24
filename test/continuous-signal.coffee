ContinuousSignal = require 'hearsay/continuous-signal'
{ assert } = require 'chai'

class Subject
  constructor: (val) -> @signal = new ContinuousSignal (@send) => @send(val)

describe "ContinuousSignal", ->
  it "starts with its current value", ->
    subject = new Subject(1)
    signal = subject.signal

    vals = []
    unsubscribe = signal.subscribe (val) ->
      vals.push val
    unsubscribe()
    assert.deepEqual vals, [1]

  it "sends to all subscribers", ->
    subject = new Subject(1)
    signal = subject.signal

    vals1 = []
    vals2 = []
    unsubscribe1 = signal.subscribe (val) ->
      vals1.push val
    unsubscribe2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10]

    unsubscribe1()
    unsubscribe2()

  it "doesn't send to a removed subscriber", ->
    subject = new Subject(1)
    signal = subject.signal

    vals1 = []
    vals2 = []
    unsubscribe1 = signal.subscribe (val) ->
      vals1.push val
    unsubscribe2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10]

    unsubscribe1()
    subject.send 20

    assert.deepEqual vals1, [1, 10]
    assert.deepEqual vals2, [1, 10, 20]

    unsubscribe2()
