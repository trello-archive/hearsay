latest = require 'hearsay/latest'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "latest", ->
  it "unpacks signals", ->
    name = new Slot("John")
    outer = new Slot(name)
    vals = []

    subscription = latest(outer).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    name.set "Mary"
    assert.deepEqual vals, ["John", "Mary"]

    subscription.remove()

  it "doesn't send values for old inner signals", ->
    name = new Slot("John")
    age = new Slot(30)
    outer = new Slot(name)
    vals = []

    subscription = latest(outer).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    outer.set age
    assert.deepEqual vals, ["John", 30]

    name.set "Mary"
    assert.deepEqual vals, ["John", 30]
    subscription.remove()
