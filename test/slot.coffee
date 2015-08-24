{ assert } = require 'chai'
Slot = require 'hearsay/slot'

describe "Slot", ->
  it "returns initial value", ->
    slot = new Slot 10
    assert slot.get() == 10

  it "allows setting", ->
    slot = new Slot 10
    slot.set 20
    assert slot.get() == 20

  describe "Slot::update", ->
    it "sets the new value", ->
      slot = new Slot 10
      slot.update (x) -> x * 2
      assert slot.get() == 20

    it "returns the updated value", ->
      slot = new Slot 10
      assert (slot.update (x) -> x * 2) == 20

  describe "Slot::watch", ->
    it "triggers immediately", ->
      invoked = false
      fail = -> invoked = true
      slot = new Slot 0
      slot.subscribe(fail)()
      assert invoked

    it "removing prevents triggering", ->
      invoked = false
      once = ->
        assert !invoked
        invoked = true
      slot = new Slot 10
      slot.subscribe(once)()
      slot.set(10)
      slot.set(20)

    it "triggers on set", ->
      count = 0
      increment = -> count++
      slot = new Slot 10
      unsubscribe = slot.subscribe increment
      assert count == 1
      slot.set 10
      assert count == 2
      slot.set 20
      assert count == 3
      unsubscribe()

    it "respects context", ->
      counter = { count: 0, increment: -> @count++ }
      slot = new Slot 10
      unsubscribe = slot.subscribe counter.increment, counter

      assert counter.count == 1
      slot.set 20
      assert counter.count == 2
      slot.set 30
      assert counter.count == 3

      unsubscribe()

    it "does not allow multiple unsubscribes", ->
      unsubscribe = new Slot(10).subscribe ->
      unsubscribe()
      assert.throws -> unsubscribe()
