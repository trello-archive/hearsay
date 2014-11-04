Signal = require 'hearsay/signal'

module.exports = class Emitter extends Signal
  constructor: ->
    super (@send) =>
