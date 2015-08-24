subscribeChanges = require 'hearsay/methods/subscribe-changes'
Emitter = require 'hearsay/emitter'
Slot = require 'hearsay/slot'
{ assert } = require 'chai'

describe "subscribeChanges", ->
  it "works with continuous signals", ->
    slot = new Slot(1)

    outgoing = []
    incoming = []

    unsubscribe = subscribeChanges.call slot,
      out: (old) -> outgoing.push old
      in: (val) -> incoming.push val

    assert.deepEqual outgoing, []
    assert.deepEqual incoming, [1]

    slot.set 2

    assert.deepEqual outgoing, [1]
    assert.deepEqual incoming, [1, 2]

    slot.set 3

    assert.deepEqual outgoing, [1, 2]
    assert.deepEqual incoming, [1, 2, 3]

    unsubscribe()

  it "respects the context argument", ->
    slot = new Slot(1)
    obj = { sum: 0 }

    unsubscribe = subscribeChanges.call slot,
      out: (old) -> @sum -= old
      in: (val) -> @sum += val
    , obj

    assert.equal obj.sum, 1
    slot.set 2
    assert.equal obj.sum, 2

    unsubscribe()

  it "calls out before in", ->
    slot = new Slot(1)

    hasRoom = true

    unsubscribe = subscribeChanges.call slot,
      out: (old) ->
        assert.isFalse(hasRoom)
        hasRoom = true
      in: (val) ->
        assert.isTrue(hasRoom)
        hasRoom = false

    slot.set 2
    slot.set 3

    unsubscribe()

  it "works with discrete signals", ->
    emitter = new Emitter()

    outgoing = []
    incoming = []

    unsubscribe = subscribeChanges.call emitter,
      out: (old) -> outgoing.push old
      in: (val) -> incoming.push val

    assert.deepEqual outgoing, []
    assert.deepEqual incoming, []

    emitter.send 1

    assert.deepEqual outgoing, []
    assert.deepEqual incoming, [1]

    emitter.send 2

    assert.deepEqual outgoing, [1]
    assert.deepEqual incoming, [1, 2]

    emitter.send 3

    assert.deepEqual outgoing, [1, 2]
    assert.deepEqual incoming, [1, 2, 3]

    unsubscribe()
