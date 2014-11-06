map = require './map'

module.exports = ->
  map.call this, (x) -> !x
