# Represents and manages a game's state

_ = require('lodash')
uuid = require('uuid')
seed = require('seed-random')
math = require('mathjs')
deepcopy = require('deepcopy')

module.exports = class Game
    BOARD_WIDTH: 50
    BOARD_HEIGHT: 30
    DOTS_PER_PLAYER: 2
    FN_ANIMATION_SPEED: 0.005 # graph units per ms

    constructor: ->
      @subscriberIds = []
      @subscriberCallbacks = {}
      @playbackTime = Date.now()
      @lastFrameTime = null
      @animationRequestID = null
      @state = null
      @data =
        rand: Math.random()
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
    # Only the server can issue this move, and only on behalf of a player
    # in the game. The game must not already have been started.
    @start: (playerId)->
      return {type: 'start', playerId: playerId}

    # Fire the given function from the currently active dot. Only the currently
    # active player can issue this move.
    @fire: (expression) ->
      return {type: 'fire', expression: expression}

    generateStateAtTimeForPlayer: (t, playerId) ->
      # If @state and t >= @state.time, we can start from there. Otherwise
      # we need to replay from the beginning.
      unless @state and t >= @state.time
        @state = 
          time: 0
          teams: [
              active: true
              players: []
            ,
              active: false
              players: []
          ]
          started: false

      while @state.time < t
        nextMove = _.find(@data.moves, (m) => m.t > @state.time)
        dt = Math.min(t, nextMove?.t || Infinity) - @state.time
        @state.time += dt

        # Apply move (if any) at t
        if nextMove?.t == @state.time
          switch nextMove.type
            when 'addPlayer'    then @_addPlayer(@state, nextMove)
            when 'removePlayer' then @_removePlayer(@state, nextMove)
            when 'start'        then @_start(@state, nextMove, playerId)
            when 'fire'         then @_fire(@state, nextMove)

        @_stepFunction(@state, @state.time, dt) if @state.fn

      return @state

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
        id: move.playerId,
        name: move.playerName,
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

    _start: (state, move, playerId) ->
      return if move.agentId? or 
                !@_getPlayer(state, move.playerId) or 
                state.started

      state.started = true
      @_generateInitialPositions(state)

      state.teams[0].active = true
      state.teams[0].players[0].active = true
      state.teams[0].players[0].dots[0].active = true

      for team, index in state.teams
        for player in team.players
          if (player.id == playerId)
            state.flipped = index > 0

    _dist: (point1, point2) ->
      Math.sqrt(
        Math.pow(point2.x - point1.x, 2) +
        Math.pow(point2.y - point1.y, 2)
      )

    # Populate players with randomly positioned dots
    _generateInitialPositions: (state) ->
      rand = seed(@data.rand)

      randomPoint = (x0, y0, width, height) ->
        x: (rand() * width) + x0
        y: (rand() * height) + y0

      # Keep track of generated dots to avoid generating two nearby dots
      dots = []

      for team, teamIndex in state.teams
        hOffset = (teamIndex-1) * (@BOARD_WIDTH/2)
        for player in team.players
          for i in [1..@DOTS_PER_PLAYER]
            until dot? && dots.every((d)=> @_dist(dot,d) > 4)
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

    # Get the active team, player, and dot.
    _getActive: (state) ->
      team = _.find(state.teams, (x) -> x.active)
      player = _.find(team.players, (x) -> x.active)
      dot = _.find(player.dots, (x) -> x.active)
      {team, player, dot}

    _fire: (state, move) ->
      active = @_getActive(state)
      return unless move.agentId == active.player.id

      compiledFunction = math.compile(move.expression)
      state.fn = {
        expression: move.expression,
        evaluate: (x) -> compiledFunction.eval(x: x),
        origin: {x: active.dot.x, y: active.dot.y},
        startTime: state.time
      }

    _stepFunction: (state, stateTime, dt) ->
      x0 = state.fn.origin.x + @FN_ANIMATION_SPEED*((stateTime-dt)-state.fn.startTime)
      xMax = state.fn.origin.x + @FN_ANIMATION_SPEED*(stateTime-state.fn.startTime)
      # TODO: collision detection and stuff here
      delete state.fn if xMax >= @BOARD_WIDTH/2

    ######################
    # Sync / subscriptions
    ######################

    # Update the game data. Use this to synchronize
    # with another Game object.
    replaceData: (newData) ->
      @data = newData
      @state = null
      @playbackTime = @data.currentTime

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
      _.extend(@data, currentTime: Date.now())
      @subscriberCallbacks[subscriberId](@data)

    # Start animating, calling callback with a game state object every frame.
    startAnimatingForPlayer: (playerId, callback) ->
      animate = (t) =>
        @playbackTime += (t - @lastFrameTime)
        @lastFrameTime = t
        callback(@generateStateAtTimeForPlayer(@playbackTime, playerId))
        @animationRequestID = requestAnimationFrame(animate)
      @animationRequestID = requestAnimationFrame(animate)

    stopAnimating: ->
      cancelAnimationFrame(@animationRequestID)
      @animationRequestID = null