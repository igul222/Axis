Geometry = require('./Geometry.coffee')
MarchingSquares = require('./MarchingSquares.js')

module.exports = class Obstacles
  @Count: 10
  @MinRadius: 1
  @MaxRadius: 3
  @PathResolution: 0.5
  @BlastRadius: 1

  constructor: (rand, xMax, yMax) ->
    @_obstacles     = @_generateObstacles(rand, xMax, yMax)
    @_antiobstacles = []
    @_generateObstaclePaths()

  _generateObstacles: (rand, xMax, yMax) ->
    StartedGameState = require('./StartedGameState.coffee')

    obstacles = []

    for i in [1..@constructor.Count]
      obstacle = Geometry.randomPoint(
        -xMax * 0.5, -yMax,
         xMax * 0.5,  yMax,
         rand
      )
      obstacle.radius = @constructor.MinRadius + (rand() * (@constructor.MaxRadius - @constructor.MinRadius))
      obstacles.push(obstacle)

    obstacles

  _generateObstaclePaths: ->
    cellSize = @constructor.PathResolution

    hitTest = (x, y) => @hitTest(x, y)

    obstaclePaths = []
    
    for obstacle in @_obstacles
      # If the obstacle is smaller than sqrt(2)*cellSize, it disappears.
      continue if obstacle.radius < Math.sqrt(2) * cellSize/2

      # Start at a known inside point and move right until we hit a boundary.
      x = obstacle.x
      y = obstacle.y
      x += cellSize until MarchingSquares.isBoundary(hitTest, x, y, cellSize)

      # Overlapping or nearby circles generate identical paths. Check if the
      # boundary point is on an existing path before generating another one.
      pathAlreadyExists = 
        obstaclePaths.some (path) ->
          path.some (point) -> 
            Math.abs(x - point.x) < cellSize and 
            Math.abs(y - point.y) < cellSize

      unless pathAlreadyExists
        path = MarchingSquares.walkPerimeter(hitTest, x, y, cellSize)
        obstaclePaths.push(path)

    @paths = obstaclePaths

  hitTest: (x, y, radius = 0) ->
    if radius > 0
      return @hitTest(x + radius, y) or 
             @hitTest(x - radius, y) or 
             @hitTest(x, y + radius) or
             @hitTest(x, y - radius)
    else
      if @_antiobstacles.some((ao) => Geometry.dist({x,y}, ao) <= @constructor.BlastRadius)
        return false

      field = (obstacle) =>
        Math.pow(obstacle.radius / Geometry.dist({x,y}, obstacle), 2)

      return @_obstacles.map(field).reduce(((a,b) -> a+b), 0) >= 1

  blast: (x, y) ->
    @_antiobstacles.push({x, y})
    @_generateObstaclePaths()