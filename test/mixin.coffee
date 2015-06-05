{ assert } = require 'chai'
HearsayMixin = require 'hearsay/mixin'
Slot = require 'hearsay/slot'
Person = require 'person'

mixin = (obj, klass) ->
  for key, value of obj
    klass.prototype[key] = value
  return

describe "Mixin", ->
  describe "subscribe", ->
    it "tracks subscribes", ->
      names = []

      mixin HearsayMixin, class Manager
        spyOn: (nameSlot) ->
          @subscribe nameSlot, (name) ->
            names.push name
          return
        stopSpying: -> @unsubscribe()

      manager = new Manager()

      john = new Person("John")
      mark = new Person("Mark")

      manager.spyOn john.name
      john.name.set "Jonathan"
      manager.spyOn mark.name
      manager.stopSpying()
      john.name.set "John"
      assert.deepEqual names, ["John", "Jonathan", "Mark"]

    it "uses this as the context", ->
      mixin HearsayMixin, class Manager
        constructor: ->
          @names = []
        spyOn: (person) ->
          @subscribe person.name, (name) ->
            @names.push name

      manager = new Manager()
      john = new Person("John")
      manager.spyOn john
      john.name.set "Jonathan"
      manager.unsubscribe()
      assert.deepEqual manager.names, ["John", "Jonathan"]

  describe "subscribeChanges", ->
    it "tracks subscriptions", ->
      mixin HearsayMixin, class Manager
        spyOn: (underling) ->
          @subscribeChanges underling,
            out: (person) -> person.active = false
            in: (person) -> person.active = true
          return
        stopSpying: -> @unsubscribe()

      manager = new Manager()

      john = new Person("John")
      mark = new Person("Mark")
      john.active = false
      mark.active = false

      activePerson = new Slot(john)

      manager.spyOn activePerson
      assert.isTrue john.active
      assert.isFalse mark.active

      activePerson.set mark
      assert.isFalse john.active
      assert.isTrue mark.active

      manager.stopSpying()
      assert.isFalse john.active
      assert.isTrue mark.active

      activePerson.set john
      assert.isFalse john.active
      assert.isTrue mark.active

    it "uses this as the context", ->
      mixin HearsayMixin, class Manager
        ins: 0
        outs: 0
        spyOn: (nameSignal) ->
          @subscribeChanges nameSignal,
            out: (nameSignal) -> @outs++
            in: (nameSignal) -> @ins++
          return
        stopSpying: -> @unsubscribe()

      manager = new Manager()
      john = new Person("John")

      assert.equal manager.ins, 0
      assert.equal manager.outs, 0

      manager.spyOn john.name
      assert.equal manager.ins, 1
      assert.equal manager.outs, 0

      john.name.set "Jonathan"
      assert.equal manager.ins, 2
      assert.equal manager.outs, 1
      manager.unsubscribe()

  describe "watch", ->
    it "tracks watches", ->
      names = []

      mixin HearsayMixin, class Manager
        spyOn: (person) ->
          @watch person, 'name', (name) ->
            names.push name
          return
        stopSpying: -> @unsubscribe()

      manager = new Manager()

      john = new Person("John")
      mark = new Person("Mark")

      manager.spyOn john
      john.name.set "Jonathan"
      manager.spyOn mark
      manager.stopSpying()
      john.name.set "John"
      assert.deepEqual names, ["John", "Jonathan", "Mark"]

    it "allows explicit unsubscribing", ->
      names = []

      mixin HearsayMixin, class Manager
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
      manager.unsubscribe()
      mark.name.set "Mark"
      assert.deepEqual names, ["John", "Jonathan", "Mark", "Matthew"]

    it "uses this as the context", ->
      mixin HearsayMixin, class Manager
        constructor: ->
          @names = []
        spyOn: (person) ->
          @watch person, 'name', (name) ->
            @names.push name

      manager = new Manager()
      john = new Person("John")
      manager.spyOn john
      john.name.set "Jonathan"
      manager.unsubscribe()
      assert.deepEqual manager.names, ["John", "Jonathan"]

    it "defaults this as the target", ->
      mixin HearsayMixin, class Manager
        constructor: ->
          @name = new Slot("Jennifer")
          @names = []
          @watch 'name', (name) ->
            @names.push name

      manager = new Manager()
      manager.name.set("Jen")
      manager.name.set("Jennifer")
      manager.unsubscribe()
      manager.name.set("Jen")
      assert.deepEqual manager.names, ["Jennifer", "Jen", "Jennifer"]
