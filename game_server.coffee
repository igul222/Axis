# The game's socket.io server
_ = require('underscore')
uuid = require('uuid')

module.exports = (io) ->

  class Game
    constructor: ->
      @players = []
      @started = false
      @gameId = uuid.v4()

    addPlayer: (socket, name) ->
      teams = _.groupBy(@players, 'team')
      team = (if teams[0] <= teams[1] then 0 else 1)

      @players.push {
        socket: socket,
        name: name,
        team: team
      }

      @_update()

    removePlayer: (socket) ->
      @players = _.filter(@players, (p) -> p.socket == socket)
      @_update()

    start: ->
      @started = true
      @_update()

    _update: ->
      data =
        players: @players.map (p) ->
          name: p.name
          team: p.team
        started: @started

      for player in @players
        player.socket.emit('update', data)

  openGame = new Game()

  io.on 'connection', (socket) ->
    currentGame = null

    socket.on 'joinGame', (name) ->
      openGame.addPlayer(socket, name)
      currentGame = openGame
      socket.emit('joinedGame', currentGame.gameId)

    socket.on 'startGame', ->
      currentGame.start()

      if currentGame == openGame
        openGame = new Game()

    socket.on 'disconnect', ->
      currentGame?.removePlayer(socket)