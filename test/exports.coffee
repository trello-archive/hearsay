Hearsay = require 'hearsay'
{ assert } = require 'chai'

describe "Hearsay", ->
  it "exports merge as a function", ->
    a = new Hearsay.Emitter()
    b = new Hearsay.Emitter()
    c = new Hearsay.Emitter()

    val = 0
    unsubscribe = Hearsay.merge(a, b, c).subscribe (x) -> val += x

    assert.equal val, 0
    a.send(1)
    assert.equal val, 1
    b.send(2)
    assert.equal val, 3
    c.send(3)
    assert.equal val, 6

    unsubscribe()

  it "exports merge as a method", ->
    a = new Hearsay.Emitter()
    b = new Hearsay.Emitter()
    c = new Hearsay.Emitter()

    val = 0
    unsubscribe = a.merge(b, c).subscribe (x) -> val += x

    assert.equal val, 0
    a.send(1)
    assert.equal val, 1
    b.send(2)
    assert.equal val, 3
    c.send(3)
    assert.equal val, 6

    unsubscribe()
