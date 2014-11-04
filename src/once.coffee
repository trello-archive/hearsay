module.exports = (message, fn) ->
  invoked = false
  return ->
    if invoked
      throw new Error(message)
    invoked = true
    fn.apply(this, arguments)

