_ = require('lodash')
uuid = require('uuid')

module.exports = class Game
  @games = {}
  @openGameId = uuid.v4()

  @getById: (id) ->
    @games[id]

  @resetOpenGame: ->
    @openGameId = uuid.v4()
    @games[@openGameId] = new Game()

  constructor: ->
    @moves = []
    @rand = Math.random()
    @subscribers = []

  # Push a move onto the game's move log and update all subscribers.
  pushMove: (move, agentId, time = Math.round(Date.now() / 10) ) ->
    move.agentId = agentId
    move.t = time
    @moves.push(move)
    @_updateAllSubscribers()

  # Register a subscriber with an id and a callback, and send an initial update
  # to that subscriber.
  subscribe: (id, callback) ->
    subscriber = {id, callback}
    @subscribers.push(subscriber)
    @_updateSubscriber(subscriber)

  # Deregister the subscriber with the given id.
  unsubscribe: (id) ->
    @subscribers = _.reject(@subscribers, (s) -> s.id == id)

  # Send an update to the given subscriber.
  _updateSubscriber: (subscriber) ->
    data = {moves: @moves, rand: @rand, currentTime: Math.round(Date.now() / 10)}
    subscriber.callback(data)

  # Send an update to all subscribers.
  _updateAllSubscribers: ->
    @_updateSubscriber(sub) for sub in @subscribers