Signal = require 'hearsay/signal'
{ assert } = require 'chai'

class Subject
  constructor: -> @signal = new Signal (@send) =>

describe "Signal", ->
  it "sends nothing initially", ->
    subject = new Subject()
    signal = subject.signal

    vals = []
    subject.send 10
    unsubscribe = signal.subscribe (val) ->
      vals.push val
    unsubscribe()
    assert.deepEqual vals, []

  it "sends to all subscribers", ->
    subject = new Subject()
    signal = subject.signal

    vals1 = []
    vals2 = []
    unsubscribe1 = signal.subscribe (val) ->
      vals1.push val
    unsubscribe2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10]

    unsubscribe1()
    unsubscribe2()

  it "doesn't send to a removed subscriber", ->
    subject = new Subject()
    signal = subject.signal

    vals1 = []
    vals2 = []
    unsubscribe1 = signal.subscribe (val) ->
      vals1.push val
    unsubscribe2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10]

    unsubscribe1()
    subject.send 20

    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10, 20]

    unsubscribe2()
