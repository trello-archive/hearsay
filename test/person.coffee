{ Slot } = require 'slots'

class Person
  constructor: (name, lover) ->
    @name = new Slot name
    @lover = new Slot lover

module.exports = Person
