switchFn = require 'hearsay/functions/switch'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "switch", ->
  it "works", ->
    pred = new Slot(true)
    name = new Slot("John")
    age = new Slot(30)

    vals = []

    unsubscribe = switchFn(pred, name, age).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    pred.set false
    assert.deepEqual vals, ["John", 30]

    age.set 40
    assert.deepEqual vals, ["John", 30, 40]

    name.set "Mary"
    pred.set true
    assert.deepEqual vals, ["John", 30, 40, "Mary"]

    unsubscribe()

  it "distincts its switch value", ->
    pred = new Slot(true)
    name = new Slot("John")
    age = new Slot(30)

    vals = []

    unsubscribe = switchFn(pred, name, age).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    pred.set true
    pred.set true
    pred.set true
    pred.set true
    assert.deepEqual vals, ["John"]

    unsubscribe()
