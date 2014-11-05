andFn = require 'hearsay/combinators/and'
orFn = require 'hearsay/combinators/or'
notFn = require 'hearsay/combinators/not'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "and", ->
  it "works", ->
    slot1 = new Slot(true)
    slot2 = new Slot(true)
    vals = []

    subscription = andFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot1.set false
    assert.deepEqual vals, [true, false]

    subscription.remove()

  it "distincts its output", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    subscription = andFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [false]

    slot1.set false
    assert.deepEqual vals, [false]

    slot1.set true
    slot2.set true
    assert.deepEqual vals, [false, true]

    subscription.remove()

describe "or", ->
  it "works", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    subscription = orFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot1.set false
    assert.deepEqual vals, [true, false]

    subscription.remove()

  it "distincts its output", ->
    slot1 = new Slot(true)
    slot2 = new Slot(false)
    vals = []

    subscription = orFn.call(slot1, slot2).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [true]

    slot2.set true
    assert.deepEqual vals, [true]

    slot1.set false
    slot2.set false
    assert.deepEqual vals, [true, false]

    subscription.remove()

describe "not", ->
  it "works", ->
    slot = new Slot(true)
    vals = []

    subscription = notFn.call(slot).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [false]

    slot.set false
    assert.deepEqual vals, [false, true]

    subscription.remove()
