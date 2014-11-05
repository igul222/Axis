math = require('mathjs')

StartedGameState = require('./StartedGameState.coffee')
FinishedGameState = require('./FinishedGameState.coffee')
Geometry = require('./Geometry.coffee')

module.exports = class FiringGameState extends StartedGameState
  @FunctionAnimationSpeed: 0.05 # graph units per ms

  @new: (old, fireMove) ->
    new FiringGameState(old, fireMove)

  constructor: (old, fireMove) ->
    super(old)

    origin = @players.active().dot
    flip = if origin.x > 0 then -1 else 1
    compiledFunction = math.compile(fireMove.expression)
    yTranslate = origin.y - compiledFunction.eval(x: 0)

    @fn = {
      expression: fireMove.expression
      origin: origin
      flip: flip
      evaluate: (x) =>
        compiledFunction.eval(x: flip*(x - origin.x)) + yTranslate
      x: origin.x
    }

  tick: ->
    @_gameStateTick()

    @fn.x += (@fn.flip * @constructor.FunctionAnimationSpeed)
    y = @fn.evaluate(@fn.x)

    # Kill dots
    for team in @players.teams
      for player in team.players
        for dot in player.dots
          if dot != @players.active().dot and 
             dot.alive and 
             Geometry.distLessThan({x: @fn.x,y: y}, dot, @players.constructor.DotRadius)

            dot.alive = false
            @updated = true

            if @players.gameOver()
              return FinishedGameState.new(this)

    # Potentially transition to the next player's turn

    hitObstacle = @obstacles.hitTest(@fn.x, y)

    insideBounds = -@constructor.XMax <= @fn.x <= @constructor.XMax and
                   -@constructor.YMax <= y     <= @constructor.YMax

    if hitObstacle
      @obstacles.blast(@fn.x, y)

    if hitObstacle or !insideBounds
      @players.advance()
      TypingFunctionGameState = require('./TypingFunctionGameState.coffee')
      return TypingFunctionGameState.new(this)
    else
      return this