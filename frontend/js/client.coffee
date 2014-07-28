# The game's socket.io client and central data store

page = require('page')
Game = require('../../game.coffee')

class Client
  constructor: ->
    @socket = io()
    @game = null
    @data =
      playerName: '',
      game: null

    @socket.on 'update', (gameState) =>
      @game?.setState(gameState)

    @socket.on 'joinedPublic', (gameId) =>
      page('/games/'+gameId)

  setPlayerName: (playerName) ->
    @data.playerName = playerName
    @_update()

  joinPublicGame: ->
    @socket.emit('joinPublic', @data.playerName)

  observe: (gameId) ->
    @game = new Game()
    @game.subscribe 'client', (state) =>
      @data.game = state
      @_update()
    @socket.emit('observe', gameId)

  leave: ->
    @game = null
    @socket.emit('leave')

  start: ->
    @socket.emit('start')

  subscribe: (callback) ->
    @callback = callback
    @_update()

  _update: ->
    @callback(@data) if @callback

module.exports = new Client()