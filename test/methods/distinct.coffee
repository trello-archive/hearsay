distinct = require 'hearsay/methods/distinct'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "distinct", ->
  it "works", ->
    slot = new Slot(1)
    vals = []

    unsubscribe = distinct.call(slot).subscribe (val) ->
      vals.push val

    slot.set 1
    slot.set 1
    slot.set 1
    slot.set 2
    slot.set 2
    slot.set 2
    slot.set 1
    slot.set 1
    slot.set 1
    assert.deepEqual vals, [1, 2, 1]

    unsubscribe()

  it "allows a custom comparison function", ->
    slot = new Slot([1])
    vals = []

    unsubscribe = distinct.call(slot, ([a], [b]) -> a == b).subscribe (val) ->
      vals.push val

    slot.set [1]
    slot.set [1]
    slot.set [1]
    slot.set [2]
    slot.set [2]
    slot.set [2]
    slot.set [1]
    slot.set [1]
    slot.set [1]
    assert.deepEqual vals, [[1], [2], [1]]

    unsubscribe()
