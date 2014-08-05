# Represents and manages a game's state

_ = require('underscore')
uuid = require('uuid')
seed = require('seed-random')

module.exports = class Game
    BOARD_WIDTH: 50
    BOARD_HEIGHT: 30
    DOTS_PER_PLAYER: 2

    constructor: ->
      @subscriberIds = []
      @subscriberCallbacks = {}
      @stateAnimation = null
      @data =
        rand: Math.random()
        t0: Date.now()
        moves: []

    ##########################
    # Moves / state generation
    ##########################

    pushMove: (agentId, move) ->
      move.t = Date.now()
      move.agentId = agentId
      @data.moves.push(move)
      @_dataUpdateAll()

    # Add a player (with given id and name) to the team with fewer players.
    # Only the server can issue this move.
    @addPlayer: (playerId, playerName) ->
      return {type: 'addPlayer', playerId: playerId, playerName: playerName}

    # Remove the player with the given id from the game if he exists.
    # Players can only remove themselves.
    @removePlayer: (playerId) ->
      return {type: 'removePlayer', playerId: playerId}

    # Start the game on behalf of the player with the given id.
    # Only the server can issue this request, and only on behalf of a player
    # in the game. The game must not already have been started.
    @start: (agentId)->
      return {type: 'start', agentId: agentId}

    @fire: (fn) ->
      return {type: 'fire', fn: fn}

    generateState: ->
      state =
        teams: [
            active: true
            players: []
          ,
            active: false
            players: []
        ]
        started: false

      for move in @data.moves
        switch move.type
          when 'addPlayer'    then @_addPlayer(state, move)
          when 'removePlayer' then @_removePlayer(state, move)
          when 'start'        then @_start(state, move)

      return state

    #########
    # Players
    #########

    _addPlayer: (state, move) ->
      return if state.started or move.agentId?

      if state.teams[0].players.length <= state.teams[1].players.length
        team = state.teams[0]
      else
        team = state.teams[1]

      team.players.push {
        id: move.id,
        name: move.name,
        active: false
        dots: []
      }

    _removePlayer: (state, move) ->
      return unless move.agentId == move.playerId
      for team in state.teams
        team.players = _.reject(team.players, (p) -> p.id == move.id)

    # Return the player with the given id, or undefined if none exists.
    _getPlayer: (state, id) ->
      players = _.flatten(_.pluck(state.teams, 'players'))
      _.find(players, (p) -> p.id == id)

    ##########
    # Gameplay
    ##########

    _start: (state, move) ->
      return unless move.agentId? and @_getPlayer(state, move.agentId) and !state.started

      state.started = true
      @_generateInitialPositions(state)

      state.teams[0].active = true
      state.teams[0].players[0].active = true
      state.teams[0].players[0].dots[0].active = true

    # Populate players with randomly positioned dots
    _generateInitialPositions: (state) ->
      rand = seed(@data.rand)

      randomPoint = (x0, y0, width, height) ->
        x: Math.floor(rand() * width) + x0
        y: Math.floor(rand() * height) + y0

      dist = (point1, point2) ->
        Math.sqrt(
          Math.pow(point2.x - point1.x, 2) +
          Math.pow(point2.y - point1.y, 2)
        )

      # Keep track of generated dots to avoid generating two nearby dots
      dots = []

      for team, teamIndex in state.teams
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
            dot.functions = []
            dot.active = false
            dots.push(dot)
            player.dots.push(dot)

    # # Advance the game by one turn, updating team/player/dot active values
    # advanceTurn: ->
    #   recursivelyAdvance = (ary) ->
    #     return unless ary?
    #     for item,i in ary
    #       if item.active
    #         item.active = false
    #         ary[(i+1) % ary.length].active = true
    #         recursivelyAdvance(item.players || item.dots || null)
    #         break
    #   recursivelyAdvance(@state.teams)

    # #attempt to make a move as the player, validate
    # moveAsPlayer: (id, move)->
    #   if validateMoveAsPlayer(id, move)
    #     getActiveDotForPlayer(id).push(move)

    # #validate whether the player is active and can make the proposed move
    # validateMoveAsPlayer: (id, move) ->
    #   player = getPlayer(id)
    #   player.active && player.team.active

    ######################
    # Sync / subscriptions
    ######################

    # Update the game data. Use this to synchronize
    # with another Game object.
    setData: (newData) ->
      @data = newData

    # Call the given callback whenever the game data changes, passing the
    # new game data as an argument. Accepts an id which you can pass to
    # unsubscribe if you want to stop the callbacks.
    dataSubscribe: (id, callback) ->
      return if _.contains(@subscriberIds, id)
      @subscriberIds.push(id)
      @subscriberCallbacks[id] = callback
      @_dataUpdate(id)

    # Stop calling the callback passed to subscribe with the given id.
    dataUnsubscribe: (id) ->
      @subscriberIds = _.without(@subscriberIds, id)
      delete @subscriberCallbacks[id] if @subscriberCallbacks[id]

    # Fire all the subscribed callbacks.
    _dataUpdateAll: ->
      for id in @subscriberIds
        @_dataUpdate(id)

    # Fire the subscribed callback with the given id only.
    _dataUpdate: (subscriberId) ->
      console.log('dataUpdate to '+subscriberId)
      @subscriberCallbacks[subscriberId](@data)

    # Subscribe to updates in the game state. Call this function with null
    # to stop receiving callbacks.
    stateSubscribe: (callback) ->
      if callback
        animate = =>
          callback(@generateState())
          requestAnimationFrame(animate)
        @stateAnimation = requestAnimationFrame(animate)
      else if @stateAnimation
        cancelAnimationFrame(@stateAnimation)