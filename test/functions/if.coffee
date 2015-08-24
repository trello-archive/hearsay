ifFn = require 'hearsay/functions/if'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
defer = require 'util/defer'
{ assert } = require 'chai'

describe "if", ->
  it "works", ->
    pred = new Slot(true)
    name = new Slot("John")
    age = new Slot(30)

    vals = []

    unsubscribe = ifFn(pred, name, age).subscribe (val) ->
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

  it "distincts its if value", ->
    pred = new Slot(true)
    name = new Slot("John")
    age = new Slot(30)

    vals = []

    unsubscribe = ifFn(pred, name, age).subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    pred.set true
    pred.set true
    pred.set true
    pred.set true
    assert.deepEqual vals, ["John"]

    unsubscribe()

  it "does not leak subscriptions", ->
    disposed1 = false
    disposed2 = false
    disposed3 = false
    disposed4 = false

    pred = new Slot(true).addDisposer -> disposed1 = true
    name1 = new Slot("John").addDisposer -> disposed2 = true
    name2 = new Slot("Mark").addDisposer -> disposed3 = true
    ifSignal = ifFn(pred, name1, name2).addDisposer -> disposed4 = true

    vals = []
    unsubscribe = ifSignal.subscribe (val) ->
      vals.push val
    assert.deepEqual vals, ["John"]

    assert !disposed1
    assert !disposed2
    assert !disposed3
    assert !disposed4

    defer()
    .tap ->
      name1.set("Mary")
      assert.deepEqual vals, ["John", "Mary"]
      assert !disposed1
      assert !disposed2
      assert !disposed3
      assert !disposed4
      defer()
    .tap ->
      pred.set(false)
      assert.deepEqual vals, ["John", "Mary", "Mark"]
      assert !disposed1
      assert !disposed2
      assert !disposed3
      assert !disposed4
      defer()
    .tap ->
      pred.set(true)
      assert.deepEqual vals, ["John", "Mary", "Mark", "Mary"]
      assert !disposed1
      assert !disposed2
      assert !disposed3
      assert !disposed4
      unsubscribe()
      assert !disposed1
      assert !disposed2
      assert !disposed3
      assert !disposed4
      defer()
    .tap ->
      assert disposed1
      assert disposed2
      assert disposed3
      assert disposed4
      return
