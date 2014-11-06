constFn = require 'hearsay/functions/const'
{ assert } = require 'chai'

describe "const", ->
  it "fires immediately", ->
    vals = []

    subscription = constFn(10).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, [10]

    subscription.remove()
