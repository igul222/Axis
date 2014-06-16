# The game's socket.io server
Game = require('./game.coffee')

module.exports = (io) ->
  games = {}
  openGame = new Game()
  games[openGame.id] = openGame

  io.on 'connection', (socket) ->
    currentGame = null

    socket.on 'joinPublicGame', (name) ->
      currentGame = openGame
      currentGame.addPlayer(socket.id, name)
      socket.emit('joinedPublicGame', currentGame.id)

    socket.on 'observeGame', (gameId) ->
      currentGame = games[gameId]
      currentGame?.subscribe socket.id, (state) ->
        socket.emit('update', state)

    socket.on 'startGame', ->
      return unless currentGame?.hasPlayer(socket.id)

      currentGame.start()
      if currentGame == openGame
        openGame = new Game()
        games[openGame.id] = openGame

    socket.on 'leaveGame', ->
      currentGame?.unsubscribe(socket.id)

    socket.on 'disconnect', ->
      currentGame?.unsubscribe(socket.id)