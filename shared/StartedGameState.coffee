seed = require('seed-random')

FinishedGameState = require('./FinishedGameState.coffee')
GameState = require('./GameState.coffee')
Obstacles = require('./Obstacles.coffee')

module.exports = class StartedGameState extends GameState
  @XMax: 25
  @YMax: 15

  @new: (old) ->
    TypingFunctionGameState = require('./TypingFunctionGameState.coffee')
    TypingFunctionGameState.new(old)

  constructor: (old) ->
    super(old)

    if old instanceof StartedGameState
      @obstacles = old.obstacles
    else
      rand = seed(@randSeed)
      @obstacles = new Obstacles(rand, @constructor.XMax, @constructor.YMax)
      @players.gameStarted(@obstacles, rand, @constructor.XMax, @constructor.YMax)

  handleMove: (move) ->
    switch move.type

      when 'removePlayer'
        # TODO: something like @advanceTurn() if dot.active
        if move.agentId == move.playerId
          @players.kill(move.playerId)
          if @players.gameOver()
            return new FinishedGameState(this)
          else if move.playerId == @players.active().player.id
            @players.advance()
          @updated = true
        return this

      else
        return super(move)