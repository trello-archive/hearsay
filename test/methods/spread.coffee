spread = require 'hearsay/methods/spread'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "spread", ->
  it "preserves continuous signals", ->
    slot = new Slot([1, 2])
    vals = []
    mapped = spread.call(slot, (a, b) -> a + b)

    unsubscribe = mapped.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [3]

    slot.set [3, 4]
    assert.deepEqual vals, [3, 7]

    unsubscribe()

  it "works with discrete signals", ->
    emitter = new Emitter()
    vals = []
    mapped = spread.call(emitter, (a, b) -> a + b)

    unsubscribe = mapped.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, []

    emitter.send [1, 2]
    assert.deepEqual vals, [3]
    emitter.send [3, 4]
    assert.deepEqual vals, [3, 7]

    unsubscribe()

