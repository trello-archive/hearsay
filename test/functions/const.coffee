constFn = require 'hearsay/functions/const'
defer = require 'util/defer'
{ assert } = require 'chai'

describe "const", ->
  it "fires immediately", ->
    vals = []

    unsubscribe = constFn(10).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [10]

    unsubscribe()

  it "follows normal disposal rules", ->
    vals = []
    addVal = (val) -> vals.push(val)
    signal = constFn(10)
    unsubscribe = signal.subscribe addVal
    assert.deepEqual vals, [10]
    unsubscribe()
    defer()
    .tap ->
      assert.throws -> signal.subscribe addVal
