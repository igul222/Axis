module.exports = 
  dist: (point1, point2) ->
    Math.sqrt(
      Math.pow(point2.x - point1.x, 2) +
      Math.pow(point2.y - point1.y, 2)
    )

  distLessThan: (point1, point2, maxDist) ->
    dx = (point2.x - point1.x)
    dy = (point2.y - point1.y)

    (dx * dx) + (dy * dy) < (maxDist * maxDist)

  randomPoint: (xMin, yMin, xMax, yMax, rand) ->
    x: (rand() * (xMax - xMin)) + xMin
    y: (rand() * (yMax - yMin)) + yMin