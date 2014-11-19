StartedGameState = require('./StartedGameState.coffee')
Expression = require('./Expression.coffee')

module.exports = class TypingFunctionGameState extends StartedGameState
  @TurnTime: 6000 # ms

  @new: (old) ->
    new TypingFunctionGameState(old)

  constructor: (old) ->
    super(old)
    @turnTime = @constructor.TurnTime

  tick: ->
    @_startedGameStateTick()
    @turnTime--
    if @turnTime == 0
      @players.advance()
      return TypingFunctionGameState.new(this)
    else
      return this

  handleMove: (move) ->
    switch move.type

      when 'fire'
        if move.agentId == @players.active().player.id and
           Expression.validate(move.expression)
          FiringGameState = require('./FiringGameState.coffee')
          return FiringGameState.new(this, move)
        else
          return this

      else
        return super(move)