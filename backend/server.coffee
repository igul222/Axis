# The game's socket.io server

Game = require('../shared/game.coffee')
uuid = require('uuid')

module.exports = (io) ->
  games = {}
  openGame = uuid.v4()
  games[openGame] = new Game()

  io.on 'connection', (socket) ->
    currentGame = null

    socket.on 'joinPublic', (name) ->
      currentGame = games[openGame]
      currentGame.pushMove(Game.addPlayer(socket.id, name), null)
      socket.emit('joinedPublic', openGame)

    socket.on 'observe', (gameId) ->
      currentGame = games[gameId]
      currentGame?.dataSubscribe socket.id, (data) ->
        socket.emit('data', data)

    socket.on 'start', ->
      currentGame?.pushMove(Game.start(socket.id), null)

      if currentGame == games[openGame] and
         currentGame.generateStateAtTimeForPlayer(Math.round(Date.now()), null).started
        openGame = uuid.v4()
        games[openGame] = new Game()

    socket.on 'pushMove', (move)->
      currentGame?.pushMove(move, socket.id)

    leaveGame = ->
      if currentGame
        currentGame.dataUnsubscribe(socket.id)
        currentGame.pushMove(Game.removePlayer(socket.id), socket.id)

    socket.on 'leave', leaveGame
    socket.on 'disconnect', leaveGame