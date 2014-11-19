math = require('mathjs')

module.exports = 
  validate: (expr) ->
    try
      result = math.compile(expr.toLowerCase()).eval(x: 0)
      return (typeof result == 'number')
    catch
      return false

  makeFn: (expr, origin, x) ->
    flip = if origin.x > 0 then -1 else 1
    compiledFunction = math.compile(expr.toLowerCase())
    yTranslate = origin.y - compiledFunction.eval(x: 0)

    return {
      expression: expr
      origin: origin
      flip: flip
      evaluate: (x) =>
        compiledFunction.eval(x: flip*(x - origin.x)) + yTranslate
      x: x
    }