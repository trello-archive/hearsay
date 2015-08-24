Promise = require 'bluebird'

module.exports = (val) ->
  new Promise (resolve) ->
    setTimeout ->
      resolve(val)
    , 1
