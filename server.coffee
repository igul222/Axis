# The game's socket.io server

Game = require('./game.coffee')

module.exports = (io) ->
  games = {}
  openGame = new Game()
  games[openGame.state.id] = openGame

  io.on 'connection', (socket) ->
    currentGame = null

    socket.on 'joinPublic', (name) ->
      currentGame = openGame
      currentGame.addPlayer(socket.id, name)
      socket.emit('joinedPublic', currentGame.state.id)

    socket.on 'observe', (gameId) ->
      currentGame = games[gameId]
      currentGame?.subscribe socket.id, (state) ->
        socket.emit('update', state)

    socket.on 'start', ->
      if currentGame?.getPlayer(socket.id)
        currentGame.start()

        if currentGame == openGame
          openGame = new Game()
          games[openGame.state.id] = openGame

    socket.on 'leave', ->
      if currentGame
        currentGame.removePlayer(socket.id)
        currentGame.unsubscribe(socket.id)

    socket.on 'disconnect', ->
      if currentGame
        currentGame.removePlayer(socket.id)
        currentGame.unsubscribe(socket.id)