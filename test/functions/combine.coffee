combine = require 'hearsay/functions/combine'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "combine", ->
  it "only sends after all signals have sent", ->
    emitter1 = new Emitter(1)
    emitter2 = new Emitter(2)
    vals = []

    unsubscribe = combine(emitter1, emitter2).subscribe (val) ->
      vals.push val

    assert.deepEqual vals, []

    emitter1.send 1
    emitter1.send 2
    emitter1.send 3

    assert.deepEqual vals, []

    emitter2.send "foo"
    assert.deepEqual vals, [[3, "foo"]]
    emitter2.send "bar"
    assert.deepEqual vals, [[3, "foo"], [3, "bar"]]
    emitter1.send 4
    assert.deepEqual vals, [[3, "foo"], [3, "bar"], [4, "bar"]]
    emitter2.send "baz"
    assert.deepEqual vals, [[3, "foo"], [3, "bar"], [4, "bar"], [4, "baz"]]

    unsubscribe()

  it "produces a continuous signal with all continuous inputs", ->
    slot1 = new Slot(1)
    slot2 = new Slot(2)
    vals = []

    unsubscribe = combine(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [[1, 2]]

    slot1.set 3
    assert.deepEqual vals, [[1, 2], [3, 2]]

    unsubscribe()

  it "produces a discrete signal with mixed inputs", ->
    slot = new Slot(1)
    emitter = new Emitter()
    vals = []

    unsubscribe = combine(slot, emitter).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, []

    emitter.send 2
    assert.deepEqual vals, [[1, 2]]

    unsubscribe()
