# Represents and manages a game's state

_ = require('underscore')
uuid = require('uuid')

module.exports = class Game

    constructor: ->
      @subscriberIds = []
      @subscriberCallbacks = {}
      @state =
        id: uuid.v4()
        teams: [
            active: false
            players: []
          ,
            active: false
            players: []
        ]
        started: false

    # Return the player with the given id, or undefined if none exists.
    getPlayer: (id) ->
      players = _.flatten(_.pluck(@state.teams, 'players'))
      _.find(players, (p) -> p.id == id)

    # Add a player (with given id and name) to the team with fewer players.
    addPlayer: (id, name) ->
      return if @started

      if @state.teams[0].players.length <= @state.teams[1].players.length
        team = @state.teams[0]
      else
        team = @state.teams[1]

      team.players.push {
        id: id,
        name: name,
        active: false
        dots: []
      }

      @_updateAll()

    # Remove the player with the given id from the game if he exists.
    removePlayer: (id) ->
      for team in @state.teams
        team.players = _.reject(team.players, (p) -> p.id == id)
      @_updateAll()

    # Start the game.
    start: ->
      @state.started = true
      @_updateAll()

    # Force-update the game state to the given state. Use this to synchronize
    # with another Game object.
    setState: (newState) ->
      @state = newState
      @_updateAll()

    # Call the given callback whenever the game state changes, passing the
    # new game state as an argument. Accepts an id which you can pass to
    # unsubscribe if you want to stop the callbacks.
    subscribe: (id, callback) ->
      return if _.contains(@subscriberIds, id)
      @subscriberIds.push(id)
      @subscriberCallbacks[id] = callback
      @_update(id)

    # Stop calling the callback passed to subscribe with the given id.
    unsubscribe: (id) ->
      @subscriberIds = _.without(@subscriberIds, id)
      delete @subscriberCallbacks[id] if @subscriberCallbacks[id]

    # Fire all the subscribed callbacks.
    _updateAll: ->
      for id in @subscriberIds
        @_update(id)

    # Fire the subscribed callback with the given id only.
    _update: (subscriberId) ->
      @subscriberCallbacks[subscriberId](@state)