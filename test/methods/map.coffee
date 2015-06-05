map = require 'hearsay/methods/map'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "map", ->
  it "preserves continuous signals", ->
    slot = new Slot(1)
    vals = []
    mapped = map.call(slot, (a) -> a * 2)

    subscription = mapped.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [2]

    slot.set 10
    assert.deepEqual vals, [2, 20]

    subscription.remove()

  it "works with discrete signals", ->
    emitter = new Emitter()
    vals = []
    mapped = map.call(emitter, (a) -> a * 2)

    subscription = mapped.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, []

    emitter.send 10
    assert.deepEqual vals, [20]

    subscription.remove()

