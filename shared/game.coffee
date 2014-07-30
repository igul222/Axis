# Represents and manages a game's state

_ = require('underscore')
uuid = require('uuid')

module.exports = class Game
    BOARD_WIDTH: 50
    BOARD_HEIGHT: 30
    DOTS_PER_PLAYER: 2

    constructor: ->
      @subscriberIds = []
      @subscriberCallbacks = {}
      @state =
        id: uuid.v4()
        teams: [
            active: true
            players: []
          ,
            active: false
            players: []
        ]
        started: false

    #########
    # Players
    #########

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

    # Return the player with the given id, or undefined if none exists.
    getPlayer: (id) ->
      players = _.flatten(_.pluck(@state.teams, 'players'))
      _.find(players, (p) -> p.id == id)

    ##########
    # Gameplay
    ##########

    # Start the game.
    start: ->
      @state.started = true
      @generateInitialPositions()

      console.log(_.sample(_.sample(@state.teams).players).dots)

      @state.teams[0].active = true
      @state.teams[0].players[0].active = true
      @state.teams[0].players[0].dots[0].active = true

      console.log(@state)
      @advanceTurn(@state)
      console.log(@state)

      @_updateAll()

    # Populate players with randomly positioned dots
    generateInitialPositions: ->

      randomPoint = (x0, y0, width, height) ->
        x: Math.floor(Math.random() * width) + x0
        y: Math.floor(Math.random() * height) + y0

      dist = (point1, point2) ->
        Math.sqrt(
          Math.pow(point2.x - point1.x, 2) +
          Math.pow(point2.y - point1.y, 2)
        )

      # Keep track of generated dots to avoid generating two nearby dots
      dots = []

      for team, teamIndex in @state.teams
        hOffset = (teamIndex-1) * (@BOARD_WIDTH/2)
        for player in team.players
          for i in [1..@DOTS_PER_PLAYER]
            until dot? && dots.every((d)-> dist(dot,d) > 4)
              dot = randomPoint(
                hOffset, 
                -@BOARD_HEIGHT/2, 
                @BOARD_WIDTH/2, 
                @BOARD_HEIGHT
              )
            dots.push(dot)
            player.dots.push(dot)

    # Advance the game by one turn, updating team/player/dot active values
    advanceTurn: ->
      recursivelyAdvance = (ary) ->
        return unless ary?
        for item,i in ary
          if item.active
            item.active = false
            ary[(i+1) % ary.length].active = true
            recursivelyAdvance(item.players || item.dots || null)
            break
      recursivelyAdvance(@state.teams)

    ######################
    # Sync / subscriptions
    ######################

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