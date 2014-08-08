# Represents and manages a game's state

_ = require('lodash')
uuid = require('uuid')
seed = require('seed-random')
math = require('mathjs')
deepcopy = require('deepcopy')
React = require('react/addons')

module.exports = class Game
    BOARD_WIDTH: 50
    BOARD_HEIGHT: 30
    DOTS_PER_PLAYER: 2

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

    blankState: ->
      t: 0
      teams: [
          active: true
          players: []
        ,
          active: false
          players: []
      ]
      started: false

    generateStateAtTime: (t) ->
      @state or= @blankState()
      
      state = if t >= @state.t then deepcopy(@state) else @blankState()

      cacheState = true
      for move in @data.moves
        continue if move.t <= state.t
        break if move.t > t
        switch move.type
          when 'addPlayer'    then cacheState = @_addPlayer(state, move) and cacheState
          when 'removePlayer' then cacheState = @_removePlayer(state, move) and cacheState
          when 'start'        then cacheState = @_start(state, move) and cacheState
          when 'fire'         then cacheState = @_fire(state, move, t) and cacheState

      state.t = t
      @state = state if cacheState
      return React.addons.update(state, t: {$set: null})

    #########
    # Players
    #########

    _addPlayer: (state, move) ->
      return true if state.started or move.agentId?

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

      return true

    _removePlayer: (state, move) ->
      return true unless move.agentId == move.playerId
      for team in state.teams
        team.players = _.reject(team.players, (p) -> p.id == move.id)
      return true

    # Return the player with the given id, or undefined if none exists.
    _getPlayer: (state, id) ->
      players = _.flatten(_.pluck(state.teams, 'players'))
      _.find(players, (p) -> p.id == id)

    ##########
    # Gameplay
    ##########

    _start: (state, move) ->
      return true if move.agentId? or 
                     !@_getPlayer(state, move.playerId) or 
                     state.started

      state.started = true
      @_generateInitialPositions(state)

      state.teams[0].active = true
      state.teams[0].players[0].active = true
      state.teams[0].players[0].dots[0].active = true

      return true

    # Populate players with randomly positioned dots
    _generateInitialPositions: (state) ->
      rand = seed(@data.rand)

      randomPoint = (x0, y0, width, height) ->
        x: (rand() * width) + x0
        y: (rand() * height) + y0

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

    # Get the active team, player, and dot.
    _getActive: (state) ->
      team = _.find(state.teams, (x) -> x.active)
      player = _.find(team.players, (x) -> x.active)
      dot = _.find(player.dots, (x) -> x.active)
      {team, player, dot}

    _fire: (state, move, time) ->
      active = @_getActive(state)
      return true unless move.agentId == active.player.id

      compiledFunction = math.compile(move.expression)
      progress = (time - move.t)/10000 # 10 second animation time
      state.fn = {
        expression: move.expression,
        evaluate: (x) -> compiledFunction.eval(x: x),
        origin: active.dot,
        xMax: active.dot.x + progress*((@BOARD_WIDTH/2)-active.dot.x)
      }

      return (progress >= 1)

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
    startAnimating: (callback) ->
      animate = (t) =>
        @playbackTime += (t - @lastFrameTime)
        @lastFrameTime = t
        callback(@generateStateAtTime(@playbackTime))
        @animationRequestID = requestAnimationFrame(animate)
      @animationRequestID = requestAnimationFrame(animate)

    stopAnimating: ->
      cancelAnimationFrame(@animationRequestID)
      @animationRequestID = null