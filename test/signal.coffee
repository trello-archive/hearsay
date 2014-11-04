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
    subscription = signal.subscribe (val) ->
      vals.push val
    subscription.remove()
    assert.deepEqual vals, []

  it "sends to all subscribers", ->
    subject = new Subject()
    signal = subject.signal

    vals1 = []
    vals2 = []
    subscription1 = signal.subscribe (val) ->
      vals1.push val
    subscription2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10]

    subscription1.remove()
    subscription2.remove()

  it "doesn't send to a removed subscriber", ->
    subject = new Subject()
    signal = subject.signal

    vals1 = []
    vals2 = []
    subscription1 = signal.subscribe (val) ->
      vals1.push val
    subscription2 = signal.subscribe (val) ->
      vals2.push val
    subject.send 10
    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10]

    subscription1.remove()
    subject.send 20

    assert.deepEqual vals1, [10]
    assert.deepEqual vals2, [10, 20]

    subscription2.remove()
