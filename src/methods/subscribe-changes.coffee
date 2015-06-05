module.exports = ({ out: fnOut, in: fnIn }, context) ->
  called = false
  old = undefined

  @subscribe (val) ->
    if called
      fnOut.call this, old
    fnIn.call this, val
    old = val
    called = true
    return
  , context
