page = require('page')

class GameClient
  constructor: ->
    @socket = io()
    @data = {
      playerName: '',
      game: null
    }

    @socket.on 'update', (gameData) =>
      @data.game = gameData
      @_update()

    @socket.on 'joinedPublicGame', (gameId) =>
      page('/games/'+gameId)

  subscribe: (callback) ->
    @callback = callback
    @_update()

  setPlayerName: (playerName) ->
    @data.playerName = playerName
    @_update()

  joinPublicGame: ->
    @socket.emit('joinPublicGame', @data.playerName)

  observe: (gameId) ->
    @socket.emit('observeGame', gameId)

  leave: ->
    @socket.emit('leaveGame')

  start: ->
    @socket.emit('startGame')

  _update: ->
    @callback(@data) if @callback


module.exports = new GameClient()