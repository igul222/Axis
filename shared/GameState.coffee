_ = require('lodash')

Players = require('./Players.coffee')

module.exports = class GameState

  @new: (randSeed) ->
    # Require lazily to avoid cyclic dependency problems
    LobbyGameState = require('./LobbyGameState.coffee')
    LobbyGameState.new(randSeed)

  constructor: (old, randSeed) ->
    if old instanceof GameState
      @randSeed = old.randSeed
      @players  = old.players
      @messages = old.messages 
      @timer   = old.timer
    else
      @randSeed = randSeed
      @players  = new Players()
      @messages = []
      @timer   = 0
    @updated = true

  tick: ->
    @_gameStateTick()
    return this

  # Hack that lets subclasses override tick() without needing
  # to deal with it returning something other than 'this'
  _gameStateTick: ->
    # Set updated every 500ms for animations
    @timer++
    @updated = true if @timer % 10 == 0

  handleMove: (move) ->
    switch move.type

      when 'sendMessage'
        @_sendMessage(move)
        @updated = true
        return this

      when 'addPlayer'
        if !move.agentId
          @players.add(move.playerId)
          @updated = true
        return this

      when 'removePlayer'
        if !move.agentId
          @players.remove(move.playerId)
          @updated = true
        return this

      else
        return this

  _sendMessage: (move)->
    @messages.push(
      sender: @players.get(move.agentId).name
      text: move.message
      time: move.t
    )