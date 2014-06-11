page = require('page')

class GameClient
  constructor: ->
    @socket = io()
    @data = {
      playerName: null,
      game: null
    }

    @socket.on 'update', (gameData) ->
      @data.game = gameData
      _update()

    @socket.on 'joinedGame', (gameId) ->
      page('/games/'+gameId)

  subscribe: (callback) ->
    @callback = callback
    _update()

  setPlayerName: (playerName) ->
    @data.playerName = playerName
    _update()

  joinGame: ->
    @socket.emit('joinGame', @data.playerName)

  _update: ->
    @callback(@data) if @callback


module.exports = new GameClient()