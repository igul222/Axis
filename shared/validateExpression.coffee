math = require('mathjs')

module.exports = (expr) ->
  try
    math.compile(expr).eval(x: 0)
    return true
  catch
    return false