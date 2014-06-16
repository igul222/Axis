# The game's socket.io server
_ = require('underscore')
uuid = require('uuid')

module.exports = (io) ->

  class Game
    constructor: ->
      @id = uuid.v4()
      @players = []
      @started = false
      @subscriberIds = []
      @subscriberCallbacks = {}

    hasPlayer: (id) ->
      @players.some((p) -> p.id == id)

    addPlayer: (id, name) ->
      return if @started

      teams = _.groupBy(@players, 'team')
      team = (if teams[0]? <= teams[1]? then 0 else 1)

      @players.push {
        id: id,
        name: name,
        team: team
      }

      @_updateAll()

    removePlayer: (id) ->
      if @hasPlayer(id)
        @players = _.reject(@players, (p) -> p.id == id)
        @_updateAll()

    subscribe: (id, callback) ->
      return if _.contains(@subscriberIds, id)
      @subscriberIds.push(id)
      @subscriberCallbacks[id] = callback
      @_update(id)

    unsubscribe: (id) ->
      @subscriberIds = _.without(@subscriberIds, id)
      delete @subscriberCallbacks[id] if @subscriberCallbacks[id]

    start: ->
      @started = true
      @_updateAll()

    _updateAll: ->
      for id in @subscriberIds
        @_update(id)

    _update: (subscriberId) ->
      data =  
        id: @id
        players: @players
        started: @started
      @subscriberCallbacks[subscriberId](data)

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