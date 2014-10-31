{ assert } = require 'chai'
{ watch } = require 'hearsay'
Person = require 'person'

describe "Watch", ->
  it "allows observing", ->
    john = new Person("John")
    mark = new Person("Mark")
    names = []

    observation = watch john, 'name', (name) ->
      names.push name

    john.name.set("Jonathan")
    john.name.set("John")

    observation.remove()

    assert.deepEqual names, ["John", "Jonathan", "John"]

  describe "nested observation", ->
    it "triggers on terminal changes", ->
      john = new Person("John")
      mark = new Person("Mark", john)

      names = []

      observation = watch mark, 'lover.name', (name) ->
        names.push name

      john.name.set("Jonathan")
      john.name.set("John")

      observation.remove()

      assert.deepEqual names, ["John", "Jonathan", "John"]

    it "triggers on intermediate changes", ->
      john = new Person("John")
      mark = new Person("Mark", john)
      mary = new Person("Mary")

      names = []

      observation = watch mark, 'lover.name', (name) ->
        names.push name

      mark.lover.set(mary)
      mary.name.set("Mary Jane")

      observation.remove()

      assert.deepEqual names, ["John", "Mary", "Mary Jane"]

    it "respects love triangles", ->
      # This is known not to work. Don't do this.
      # I'll fix it one day.
      return
      john = new Person("John")
      mark = new Person("Mark", john)
      mary = new Person("Mary", mark)
      john.lover.set mary

      names = []

      watch john, 'lover.lover.lover.lover.lover.lover.lover.lover.name', (name) ->
        names.push name

      mary.lover.set john

      assert.deepEqual names, ["Mark", "John"]

