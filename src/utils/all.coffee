module.exports = (list, pred = (a) -> a) ->
  for x in list
    if !pred(x)
      return false
  return true
