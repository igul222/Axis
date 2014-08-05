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

    @socket.on 'data', (data) =>
      console.log('update received: '+JSON.stringify(data,null,4))
      if @game
        @game.setData(data)
      else
        @game = new Game()
        @game.setData(data)
        @game.stateSubscribe (state) =>
          @data.gameState = state
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

  pushMove: (move) ->
    @socket.emit('pushMove', move)

  subscribe: (callback) ->
    @callback = callback
    @_update()

  _update: ->
    @callback(@data) if @callback

module.exports = new Client()