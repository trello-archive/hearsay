{ assert } = require 'chai'
Slot = require 'hearsay/slot'
watch = require 'hearsay/watch'
Person = require 'person'

describe "Watch", ->
  it "allows observing", ->
    john = new Person("John")
    mark = new Person("Mark")
    names = []

    unsubscribe = watch john, 'name', (name) ->
      names.push name

    john.name.set("Jonathan")
    john.name.set("John")

    unsubscribe()

    assert.deepEqual names, ["John", "Jonathan", "John"]

  it "works with array paths", ->
    john = new Person("John")
    john['.'] = dotSlot = new Slot("!")

    dots = []
    unsubscribe = watch john, ['.'], (dot) ->
      dots.push dot

    dotSlot.set "?"
    assert.deepEqual dots, ["!", "?"]
    unsubscribe()

  it "requires a path", ->
    john = new Person("John")
    assert.throws -> watch john, [], ->

  describe "nested observation", ->
    it "triggers on terminal changes", ->
      john = new Person("John")
      mark = new Person("Mark", john)

      names = []

      unsubscribe = watch mark, 'lover.name', (name) ->
        names.push name

      john.name.set("Jonathan")
      john.name.set("John")

      unsubscribe()

      assert.deepEqual names, ["John", "Jonathan", "John"]

    it "triggers on intermediate changes", ->
      john = new Person("John")
      mark = new Person("Mark", john)
      mary = new Person("Mary")

      names = []

      unsubscribe = watch mark, 'lover.name', (name) ->
        names.push name

      mark.lover.set(mary)
      mary.name.set("Mary Jane")

      unsubscribe()

      assert.deepEqual names, ["John", "Mary", "Mary Jane"]

    it "respects love triangles", ->
      john = new Person("John")
      mark = new Person("Mark", john)
      mary = new Person("Mary", mark)
      john.lover.set mary

      names = []

      watch john, 'lover.lover.lover.lover.lover.lover.lover.lover.name', (name) ->
        names.push name

      mary.lover.set john

      assert.deepEqual names, ["Mark", "John"]

    it "respects a fickle sort of cyclic romance", ->
      john = new Person("John")
      john.lover.set john

      mary = new Person("Mary")
      mary.lover.set mary

      names = []

      watch john, 'lover.lover.lover.lover.lover.lover.lover.lover.name', (name) ->
        names.push name

      john.lover.set john
      john.lover.set mary
      john.lover.set john
      john.lover.set mary

      assert.deepEqual names, ["John", "John", "Mary", "John", "Mary"]

