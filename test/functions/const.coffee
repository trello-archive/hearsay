constFn = require 'hearsay/functions/const'
{ assert } = require 'chai'

describe "const", ->
  it "fires immediately", ->
    vals = []

    unsubscribe = constFn(10).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [10]

    unsubscribe()
