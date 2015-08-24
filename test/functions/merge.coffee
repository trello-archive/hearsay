merge = require 'hearsay/functions/merge'
ContinuousSignal = require 'hearsay/continuous-signal'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
defer = require 'util/defer'
{ assert } = require 'chai'

describe "merge", ->
  it "sends after the first signal sends", ->
    emitter1 = new Emitter()
    emitter2 = new Emitter()
    vals = []

    unsubscribe = merge(emitter1, emitter2).subscribe (val) ->
      vals.push val

    assert.deepEqual vals, []
    emitter1.send 1
    emitter1.send 2
    emitter1.send 3

    assert.deepEqual vals, [1, 2, 3]

    emitter2.send 4
    emitter2.send 5
    emitter1.send 6

    assert.deepEqual vals, [1, 2, 3, 4, 5, 6]

    unsubscribe()

  it "produces a discrete signal with all continuous inputs", ->
    slot1 = new Slot(1)
    slot2 = new Slot(2)

    merged = merge(slot1, slot2)

    assert merged !instanceof ContinuousSignal

  it "produces a discrete signal with mixed inputs", ->
    slot = new Slot(1)
    emitter = new Emitter()

    merged = merge(slot, emitter)

    assert merged !instanceof ContinuousSignal

  it "does not leak its underlying signals", ->
    disposed1 = false
    disposed2 = false
    disposed3 = false

    signal1 = new Slot(1).addDisposer -> disposed1 = true
    signal2 = new Emitter().addDisposer -> disposed2 = true
    merge(signal1, signal2).addDisposer -> disposed3 = true

    assert !disposed1
    assert !disposed2
    assert !disposed3
    defer()
    .tap ->
      assert disposed1
      assert disposed2
      assert disposed3
