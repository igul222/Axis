seed = require('seed-random')
uuid = require('uuid')

FinishedGameState = require('./FinishedGameState.coffee')
GameState = require('./GameState.coffee')
Obstacles = require('./Obstacles.coffee')

module.exports = class StartedGameState extends GameState
  @XMax: 25
  @YMax: 15
  @SoundDurations:
    fire: 200
    obstacleHit: 200
    playerHit: 200

  @new: (old) ->
    TypingFunctionGameState = require('./TypingFunctionGameState.coffee')
    TypingFunctionGameState.new(old)

  constructor: (old) ->
    super(old)

    if old instanceof StartedGameState
      @obstacles = old.obstacles
      @sound     = old.sound
    else
      rand = seed(@randSeed)
      @obstacles = new Obstacles(rand, @constructor.XMax, @constructor.YMax)
      @sound     = null
      @players.gameStarted(@obstacles, rand, @constructor.XMax, @constructor.YMax)

  handleMove: (move) ->
    switch move.type

      when 'removePlayer'
        if move.agentId == null
          @players.kill(move.playerId)
          if @players.gameOver()
            return new FinishedGameState(this)
          else if move.playerId == @players.active().player.id
            @players.advance()
          @updated = true
        return this

      when 'setExpressions'
        player = @players.get(move.agentId)
        if player and player.dots
          for dot, index in player.dots
            # TODO: fix this awful awful hack
            unless dot.expression == '' and move.expressions[index] == 'sin(x)'
              dot.expression = move.expressions[index]
          @updated = true
        return this

      else
        return super(move)

  tick: ->
    @_startedGameStateTick()
    return this

  _startedGameStateTick: ->
    @_gameStateTick()
    if @sound
      @sound._timeRemaining--
      if @sound._timeRemaining == 0
        @sound = null
        @updated = true

  playSound: (sound) ->
    @sound =
      id: uuid.v4()
      name: sound
      _timeRemaining: @constructor.SoundDurations[sound]
    @updated = true