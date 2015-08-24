Signal = require 'hearsay/signal'
Promise = require 'bluebird'
defer = require 'util/defer'
{ assert } = require 'chai'

getDisposed = ->
  defer(new Signal ->)

describe "Disposers", ->
  it "are invoked on the next tick", ->
    disposed = false
    new Signal ->
      -> disposed = true

    assert !disposed, "Already disposed"
    defer()
    .tap -> assert disposed, "Not disposed yet"

  it "are not invoked if a signal has users", ->
    disposed = false
    signal = new Signal ->
      -> disposed = true

    assert !disposed, "Already disposed"
    stopUsing = signal.use()
    defer()
    .tap ->
      assert !disposed, "Disposed early"
      stopUsing()
      assert !disposed, "Disposed synchronously after unuse"
      defer()
    .tap ->
      assert disposed, "Did not dispose"

  it "subscribing counts as a use", ->
    disposed = false
    signal = new Signal ->
      -> disposed = true

    assert !disposed, "Already disposed"
    observation = signal.subscribe(->)
    defer()
    .tap ->
      assert !disposed, "Disposed even though there was a subscriber"
      observation.remove()
      assert !disposed, "Disposed synchronously after unsubscribe"
      defer()
    .tap ->
      assert disposed, "Did not dispose"

  it "deriving a new signal counts as a use", ->
    disposed1 = false
    signal1 = new Signal ->
      -> disposed1 = true

    disposed2 = false
    signal2 = signal1.derive ->
      -> disposed2 = true

    assert !disposed1, "Already disposed signal1"
    assert !disposed2, "Already disposed signal2"
    defer()
    .tap ->
      assert !disposed1, "Disposed signal1 even though derived signal2 depends on it"
      assert disposed2, "Didn't dispose signal2 even though it's unused"
      defer()
    .tap ->
      assert disposed1, "Didn't dispose signal1"
      assert disposed2, "signal2 came back from the dead"

  it "disposing of a derived signal will not synchronously dispose of the underlying signal", ->
    disposed1 = false
    signal1 = new Signal ->
      -> disposed1 = true

    disposed2 = false
    signal2 = signal1.derive ->
      -> disposed2 = true

    assert !disposed1, "Already disposed signal1"
    assert !disposed2, "Already disposed signal2"
    defer()
    .then ->
      assert !disposed1, "Disposed signal1 even though derived signal2 depends on it"
      assert disposed2, "Didn't dispose signal2 even though it's unused"
      defer(signal1.use())
    .tap (unuse1) ->
      assert !disposed1, "Disposed signal1 even though we explicitly used it"
      assert disposed2, "signal2 came back from the dead"
      unuse1()
      assert !disposed1, "Disposed signal1 synchronously after unuse"
      defer()
    .tap ->
      assert disposed1, "Didn't dispose signal1"
      assert disposed2, "signal2 came back from the dead"

describe "Signal::use", ->
  it "it is an error to call unuse more than once", ->
    signal = new Signal (send) ->
      outerSend = send
      return
    unuse = signal.use()
    assert.doesNotThrow -> unuse()
    assert.throws -> unuse()

describe "Disposed signals", ->
  it "cannot send after disposal", ->
    outerSend = null
    new Signal (send) ->
      outerSend = send
      return

    assert.doesNotThrow -> outerSend(5)
    defer().tap ->
      assert.throws -> outerSend(5)

  it "cannot be used after disposal", ->
    getDisposed()
    .tap (sig) ->
      assert.throws -> sig.use()

  it "cannot be subscribed to after disposal", ->
    getDisposed()
    .tap (sig) ->
      assert.throws -> sig.subscribe()
