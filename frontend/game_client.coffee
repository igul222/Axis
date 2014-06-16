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

    @socket.on 'joinedPublic', (gameId) =>
      page('/games/'+gameId)

  subscribe: (callback) ->
    @callback = callback
    @_update()

  setPlayerName: (playerName) ->
    @data.playerName = playerName
    @_update()

  joinPublicGame: ->
    @socket.emit('joinPublic', @data.playerName)

  observe: (gameId) ->
    @socket.emit('observe', gameId)

  leave: ->
    @socket.emit('leave')

  start: ->
    @socket.emit('start')

  _update: ->
    @callback(@data) if @callback


module.exports = new GameClient()