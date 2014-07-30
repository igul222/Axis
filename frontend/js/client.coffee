# The game's socket.io client and central data store

page = require('page')
Game = require('../../shared/game.coffee')

class Client
  constructor: ->
    @socket = io()
    @game = null
    @data =
      playerName: '',
      game: null

    @socket.on 'update', (gameState) =>
      if @game
        @game.setState(gameState)
      else
        @game = new Game()
        @game.setState(gameState)
        @game.subscribe 'client', (state) =>
          @data.game = state
          @_update()

    @socket.on 'joinedPublic', (gameId) =>
      page('/games/'+gameId)

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

  subscribe: (callback) ->
    @callback = callback
    @_update()

  _update: ->
    @callback(@data) if @callback

module.exports = new Client()