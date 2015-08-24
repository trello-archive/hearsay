filter = require 'hearsay/methods/filter'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "filter", ->
  it "works", ->
    emitter = new Emitter()
    vals = []
    filtered = filter.call(emitter, (a) -> a % 2 == 0)

    unsubscribe = filtered.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, []

    emitter.send 1
    emitter.send 5
    emitter.send 3
    assert.deepEqual vals, []

    emitter.send 2
    emitter.send 3
    emitter.send 4
    assert.deepEqual vals, [2, 4]

    unsubscribe()
