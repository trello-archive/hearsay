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

  describe "Slot::watch", ->
    it "triggers immediately", ->
      invoked = false
      fail = -> invoked = true
      slot = new Slot 0
      slot.watch(fail).remove()
      assert invoked

    it "removing prevents triggering", ->
      invoked = false
      once = ->
        assert !invoked
        invoked = true
      slot = new Slot 10
      slot.watch(once).remove()
      slot.set(10)
      slot.set(20)

    it "triggers on set", ->
      count = 0
      increment = -> count++
      slot = new Slot 10
      observation = slot.watch increment
      assert count == 1
      slot.set 10
      assert count == 2
      slot.set 20
      assert count == 3
      observation.remove()

    it "respects context", ->
      counter = { count: 0, increment: -> @count++ }
      slot = new Slot 10
      observation = slot.watch counter.increment, counter

      assert counter.count == 1
      slot.set 20
      assert counter.count == 2
      slot.set 30
      assert counter.count == 3

      observation.remove()

    it "does not allow multiple .removes()", ->
      observation = new Slot(10).watch ->
      observation.remove()
      assert.throws observation.remove

