GameState = require('./GameState.coffee')
StartedGameState = require('./StartedGameState.coffee')

module.exports = class LobbyGameState extends GameState

  @new: (randSeed) ->
    new LobbyGameState(randSeed)

  constructor: (randSeed) ->
    super(null, randSeed)

  handleMove: (move) ->
    switch move.type

      when 'changeName'
        if @players.get(move.agentId)
          @players.changeName(move.agentId, move.name)
          @updated = true
        return this

      when 'switchTeam'
        @players.switchTeam(move.playerId)
        @updated = true
        return this
          
      when 'start'
        if @players.get(move.agentId) and 
           @players.teams[0].players.length > 0 and
           @players.teams[1].players.length > 0
          return StartedGameState.new(this)
        else
          return this

      else
        return super(move)