# The game's socket.io server
_ = require('underscore')
uuid = require('uuid')

module.exports = (io) ->

  class Game
    constructor: ->
      @id = uuid.v4()
      @players = []
      @observers = []
      @started = false

    hasPlayer: (socket) ->
      @players.some((p) -> p.socket == socket)

    addPlayer: (socket, name) ->
      return if @started

      teams = _.groupBy(@players, 'team')
      team = (if teams[0]? <= teams[1]? then 0 else 1)

      @players.push {
        socket: socket,
        name: name,
        team: team
      }

      @_updateAll()
      @addObserver(socket)

    addObserver: (socket) ->
      return if _.contains(@observers, socket)
      @observers.push(socket)
      @_update(socket)

    removePlayerOrObserver: (socket) ->
      @observers = _.without(@observers, socket)

      if @hasPlayer(socket)
        @players = _.reject(@players, (p) -> p.socket == socket)
        @_updateAll()

    start: ->
      @started = true
      @_updateAll()

    _update: (socket) ->
      data =  
        id: @id
        players: @players.map (p) ->
          name: p.name
          team: p.team
        started: @started
      socket.emit('update', data)

    _updateAll: ->
      for socket in @observers
        @_update(socket)

  games = {}
  openGame = new Game()
  games[openGame.id] = openGame

  io.on 'connection', (socket) ->
    currentGame = null

    socket.on 'joinPublicGame', (name) ->
      currentGame = openGame
      currentGame.addPlayer(socket, name)
      socket.emit('joinedPublicGame', currentGame.id)

    socket.on 'observeGame', (gameId) ->
      currentGame = games[gameId]
      currentGame?.addObserver(socket)

    socket.on 'startGame', ->
      return unless currentGame.hasPlayer(socket)
      currentGame.start()
      if currentGame == openGame
        openGame = new Game()
        games[openGame.id] = openGame

    socket.on 'leaveGame', ->
      currentGame?.removePlayerOrObserver(socket)

    socket.on 'disconnect', ->
      currentGame?.removePlayerOrObserver(socket)