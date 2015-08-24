andFn = require 'hearsay/methods/and'
orFn = require 'hearsay/methods/or'
notFn = require 'hearsay/methods/not'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "and", ->
  it "works", ->
    slot1 = new Slot(true)
    slot2 = new Slot(true)
    vals = []

    unsubscribe = andFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot1.set false
    assert.deepEqual vals, [true, false]

    unsubscribe()

  it "distincts its output", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    unsubscribe = andFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [false]

    slot1.set false
    assert.deepEqual vals, [false]

    slot1.set true
    slot2.set true
    assert.deepEqual vals, [false, true]

    unsubscribe()

describe "or", ->
  it "works", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    unsubscribe = orFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot1.set false
    assert.deepEqual vals, [true, false]

    unsubscribe()

  it "distincts its output", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    unsubscribe = orFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot2.set true
    assert.deepEqual vals, [true]

    slot1.set false
    slot2.set false
    assert.deepEqual vals, [true, false]

    unsubscribe()

describe "not", ->
  it "works", ->
    slot = new Slot(true)
    vals = []

    unsubscribe = notFn.call(slot).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [false]

    slot.set false
    assert.deepEqual vals, [false, true]

    unsubscribe()
