{ assert } = require 'chai'
Hearsay = require 'hearsay'
Person = require 'person'

mixin = (obj, klass) ->
  for key, value of obj
    klass.prototype[key] = value
  return

describe "Mixin", ->
  it "tracks watches", ->
    names = []

    mixin Hearsay.mixin, class Manager
      spyOn: (person) ->
        @watch person, 'name', (name) ->
          names.push name
        return
      stopSpying: -> @unwatch()

    manager = new Manager()

    john = new Person("John")
    mark = new Person("Mark")

    manager.spyOn john
    john.name.set "Jonathan"
    manager.spyOn mark
    manager.stopSpying()
    john.name.set "John"
    assert.deepEqual names, ["John", "Jonathan", "Mark"]

  it "allows explicit unwatching", ->
    names = []

    mixin Hearsay.mixin, class Manager
      spyOn: (person) ->
        return @watch person, 'name', (name) ->
          names.push name

    manager = new Manager()

    john = new Person("John")
    mark = new Person("Mark")

    johnSpying = manager.spyOn john
    john.name.set "Jonathan"
    manager.spyOn mark
    johnSpying.remove()
    john.name.set "John"
    mark.name.set "Matthew"
    manager.unwatch()
    mark.name.set "Mark"
    assert.deepEqual names, ["John", "Jonathan", "Mark", "Matthew"]

  it "uses this as the context", ->
    mixin Hearsay.mixin, class Manager
      constructor: ->
        @names = []
      spyOn: (person) ->
        @watch person, 'name', (name) ->
          @names.push name

    manager = new Manager()
    john = new Person("John")
    manager.spyOn john
    john.name.set "Jonathan"
    manager.unwatch()
    assert.deepEqual manager.names, ["John", "Jonathan"]

  it "defaults this as the target", ->
    mixin Hearsay.mixin, class Manager
      constructor: ->
        @name = new Hearsay.Slot("Jennifer")
        @names = []
        @watch 'name', (name) ->
          @names.push name

    manager = new Manager()
    manager.name.set("Jen")
    manager.name.set("Jennifer")
    manager.unwatch()
    manager.name.set("Jen")
    assert.deepEqual manager.names, ["Jennifer", "Jen", "Jennifer"]
