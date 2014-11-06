math = require('mathjs')

module.exports = (expr) ->
  try
    result = math.compile(expr).eval(x: 0)
    return (typeof result == 'number')
  catch
    return false