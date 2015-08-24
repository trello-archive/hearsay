latest = require 'hearsay/methods/latest'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
defer = require 'util/defer'
{ assert } = require 'chai'

describe "latest", ->
  it "unpacks signals", ->
    name = new Slot("John")
    outer = new Slot(name)
    vals = []

    unsubscribe = latest.call(outer).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    name.set "Mary"
    assert.deepEqual vals, ["John", "Mary"]

    unsubscribe()

  it "doesn't send values for old inner signals", ->
    name = new Slot("John")
    age = new Slot(30)
    outer = new Slot(name)
    vals = []

    unsubscribe = latest.call(outer).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    outer.set age
    assert.deepEqual vals, ["John", 30]

    name.set "Mary"
    assert.deepEqual vals, ["John", 30]
    unsubscribe()

  it "doesn't leak signals", ->
    disposed1 = false
    disposed2 = false
    disposed3 = false
    disposed4 = false
    disposedOuter = false

    signal1 = new Slot(1).addDisposer -> disposed1 = true
    outerSlot = new Slot(signal1)

    outerSignal = latest.call(outerSlot).addDisposer -> disposedOuter = true

    vals = []
    unsubscribe = outerSignal.subscribe (val) -> vals.push val
    assert.deepEqual vals, [1]

    ensureAll = -> assert(!disposed1 && !disposed2 && !disposed3 && !disposed4 && !disposedOuter, "ensureAll")
    ensureAllButOne = -> assert(disposed1 && !disposed2 && !disposed3 && !disposed4 && !disposedOuter, "ensureAllButOne")

    ensureAll()

    defer()
    .tap ->
      ensureAll()

      signal1.set 10
      assert.deepEqual vals, [1, 10], "wrong values"
      defer()
    .tap ->
      ensureAll()
      outerSlot.set(new Slot(2).addDisposer -> disposed2 = true)
      assert.deepEqual vals, [1, 10, 2], "wrong values"
      ensureAll()
      defer()
    .tap ->
      ensureAllButOne()
      outerSlot.set(new Slot(3).addDisposer -> disposed3 = true)
      assert.deepEqual vals, [1, 10, 2, 3], "wrong values"
      ensureAllButOne()
      outerSlot.set(new Slot(4).addDisposer -> disposed4 = true)
      assert.deepEqual vals, [1, 10, 2, 3, 4], "wrong values"
      ensureAllButOne()
      defer()
    .tap ->
      assert(disposed1 && disposed2 && disposed3 && !disposed4 && !disposedOuter)
      assert.deepEqual vals, [1, 10, 2, 3, 4], "wrong values"
      outerSlot.get().set(40)
      assert.deepEqual vals, [1, 10, 2, 3, 4, 40], "wrong values"
      unsubscribe()
      defer()
    .tap ->
      assert disposed1
      assert disposed2
      assert disposed3
      assert !disposed4
      assert disposedOuter
      defer()
    .tap ->
      assert disposed1
      assert disposed2
      assert disposed3
      assert disposed4
      assert disposedOuter
