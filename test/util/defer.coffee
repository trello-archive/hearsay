Promise = require 'bluebird'
timeout = require './timeout'

module.exports = (val) ->
  new Promise (resolve) ->
    timeout ->
      resolve(val)
      return
    return
