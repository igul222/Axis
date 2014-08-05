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
      currentGame.pushMove(null, Game.addPlayer(socket.id, name))
      socket.emit('joinedPublic', openGame)

    socket.on 'observe', (gameId) ->
      currentGame = games[gameId]
      currentGame?.dataSubscribe socket.id, (data) ->
        socket.emit('data', data)

    socket.on 'start', ->
      currentGame?.pushMove(null, Game.start(socket.id))

      if currentGame == games[openGame] and currentGame.generateState().started
        openGame = uuid.v4()
        games[openGame] = new Game()

    socket.on 'pushMove', (move)->
      currentGame?.pushMove(socket.id, move)

    socket.on 'leave', ->
      if currentGame
        currentGame.pushMove(socket.id, Game.removePlayer(socket.id))
        currentGame.dataUnsubscribe(socket.id)

    socket.on 'disconnect', ->
      if currentGame
        currentGame.pushMove(socket.id, Game.removePlayer(socket.id))
        currentGame.dataUnsubscribe(socket.id)