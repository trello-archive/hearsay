combine = require '../functions/combine'
distinct = require './distinct'
map = require './map'

module.exports = (other) ->
  distinct.call map.call combine(this, other), ([a, b]) -> a || b
