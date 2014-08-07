# The game's socket.io client and central data store

page = require('page')
Game = require('../../shared/game.coffee')

class Client
  constructor: ->
    @socket = io()
    @game = null
    @data =
      playerName: '',
      gameState: null

  setPlayerName: (playerName) ->
    @data.playerName = playerName
    @_update()

  joinPublicGame: ->
    @socket.on('joinedPublic', @_joinedPublicGame)
    @socket.emit('joinPublic', @data.playerName)

  _joinedPublicGame: (gameId) =>
    page('/games/'+gameId)
    @socket.removeListener('joinedPublic', @_joinedPublicGame)

  observe: (gameId) ->
    @socket.on('data', @_receivedData)
    @socket.emit('observe', gameId)

  _receivedData: (data) =>
    if !@game
      @game = new Game()
      @game.startAnimating (state) =>
        @data.gameState = state
        @_update()
    @game.replaceData(data)

  leave: ->
    @socket.removeListener('data', @_receivedData)
    @socket.emit('leave')
    @game.stopAnimating()
    @game = null

  start: ->
    @socket.emit('start')

  pushMove: (move) ->
    @socket.emit('pushMove', move)

  subscribe: (callback) ->
    @callback = callback
    @_update()

  _update: ->
    @callback(@data) if @callback

module.exports = new Client()