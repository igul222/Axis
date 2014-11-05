GameState = require('./GameState.coffee')

module.exports = class GameStateGenerator

  constructor: (@game) ->
    @state = GameState.new(0.5)
    @time = @game.moves[0].t - 1
    @nextMoveIndex = 0
    @nextMoveTime = @game.moves[0].t

  # only ever call this with monotonically increasing time values!
  generateAtTime: (time) ->
    while @time < time
      @time++

      @state = @state.tick()

      if @time == @nextMoveTime

        @state = @state.handleMove(@game.moves[@nextMoveIndex])

        if @nextMoveIndex + 1 < @game.moves.length
          @nextMoveIndex++
          @nextMoveTime = @game.moves[@nextMoveIndex].t

    return @state