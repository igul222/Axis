# Represents and manages a game's state

_ = require('lodash')
uuid = require('uuid')
seed = require('seed-random')
math = require('mathjs')
deepcopy = require('deepcopy')

module.exports = class Game
    X_MAX: 25
    Y_MAX: 15
    DOTS_PER_PLAYER: 2
    FN_ANIMATION_SPEED: 0.005 # graph units per ms
    DOT_RADIUS: 1
    TURN_TIME: 60000 # ms
    OBSTACLE_COUNT: 5
    OBSTACLE_RADIUS: 5
    ANTIOBSTACLE_RADIUS: 1

    constructor: ->
      @subscriberIds = []
      @subscriberCallbacks = {}
      @playbackTime = Math.round(Date.now())
      @lastFrameTime = null
      @animationRequestID = null
      @state = null
      @data =
        t0: 0
        rand: Math.random()
        moves: {}
      @_resetState()

    ##########################
    # Moves / state generation
    ##########################

    pushMove: (move, agentId, time) ->
      move.t = time || Math.round(Date.now())
      move.agentId = agentId
      offset = 0
      offset += 1 while @data.moves[move.t + offset]
      @data.moves[move.t + offset] = move
      @data.t0 = move.t if @data.t0 == 0
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

    _resetState: (playerId = null) ->
      @state = 
        updated: true
        playerId: playerId
        time: (@data.t0 - 1)
        started: false
        turnTime: @TURN_TIME
        teams: [
            active: true
            players: []
          ,
            active: false
            players: []
        ]
        obstacles: []
        antiobstacles: []
        started: false

    # Updates @state to the given time and player, returning @state.
    generateStateAtTimeForPlayer: (t, playerId = null) ->
      # If @state and t >= @state.time, we can start from there. Otherwise
      # we need to replay from the beginning.
      @_resetState(playerId) unless @state and t >= @state.time and 
                                    playerId == @state.playerId

      while @state.time < t
        @state.time++

        if @state.started and !@state.fn
          @state.turnTime--
          
          if @state.turnTime <= 0
            @state.turnTime += @TURN_TIME
            @_advanceTurn()

          if @state.turnTime % 1000 == 0
            @state.updated = true
            @state.displayTurnTime = @state.turnTime / 1000

        @_processCollisions() if @state.fn

        # Apply move (if any) at state.time
        if @data.moves[@state.time]
          @state.updated = true
          move = @data.moves[@state.time]
          switch move.type
            when 'addPlayer'    then @_addPlayer(move)
            when 'removePlayer' then @_removePlayer(move)
            when 'start'        then @_start(move)
            when 'fire'         then @_fire(move)

      return @state

    #########
    # Players
    #########

    _addPlayer: (move) ->
      return if @state.started or move.agentId?

      if @state.teams[0].players.length <= @state.teams[1].players.length
        team = @state.teams[0]
      else
        team = @state.teams[1]

      team.players.push {
        id: move.playerId,
        name: move.playerName,
        active: false
        dots: []
      }

    _removePlayer: (move) ->
      return unless move.agentId == move.playerId
      for team in @state.teams
        team.players = _.reject(team.players, (p) -> p.id == move.id)

    # Return the player with the given id, or undefined if none exists.
    _getPlayer: (id) ->
      players = _.flatten(_.pluck(@state.teams, 'players'))
      _.find(players, (p) -> p.id == id)

    ##########
    # Gameplay
    ##########

    _start: (move) ->
      return if move.agentId? or 
                !@_getPlayer(move.playerId) or 
                @state.started

      @state.started = true
      @_generateInitialPositions()

      recursivelySetActive = (ary) ->
        return unless ary?
        ary[0].active = true
        for item in ary
          recursivelySetActive(item.players || item.dots || null)
      recursivelySetActive(@state.teams)

      for team, index in @state.teams
        for player in team.players
          if (player.id == @state.playerId)
            @state.flipped = index > 0

    _dist: (point1, point2) ->
      Math.sqrt(
        Math.pow(point2.x - point1.x, 2) +
        Math.pow(point2.y - point1.y, 2)
      )

    # Populate players with randomly positioned dots
    _generateInitialPositions: ->
      rand = seed(@data.rand)

      randomPoint = (x0, y0, width, height) ->
        x: (rand() * width) + x0
        y: (rand() * height) + y0

      for i in [1..@OBSTACLE_COUNT]
        obstacle = randomPoint(
          -@X_MAX,
          -@Y_MAX,
          @X_MAX*2,
          @Y_MAX*2
        )
        obstacle.radius = rand()*10
        @state.obstacles.push(obstacle)

      # Keep track of generated dots to avoid generating two nearby dots
      dots = []

      for team, teamIndex in @state.teams
        hOffset = (teamIndex-1) * (@X_MAX)
        for player in team.players
          for i in [1..@DOTS_PER_PLAYER]
            until dot? and 
                  dots.every((d) => @_dist(dot,d) > 4) and 
                  @state.obstacles.every((o) => @_dist(dot,o) > o.radius)
              dot = randomPoint(
                hOffset,
                -@Y_MAX,
                @X_MAX,
                @Y_MAX*2
              )
            dot.alive = true
            dot.active = false
            dots.push(dot)
            player.dots.push(dot)

    # # Advance the game by one turn, updating team/player/dot active values
    _advanceTurn: ->
      recursivelyAdvance = (ary) ->
        return unless ary?
        for item,i in ary
          if item.active
            item.active = false
            ary[(i+1) % ary.length].active = true
            recursivelyAdvance(item.players || item.dots || null)
            break
      recursivelyAdvance(@state.teams)
      @state.updated = true

    # Get the active team, player, and dot.
    _getActive: ->
      team = _.find(@state.teams, (x) -> x.active)
      player = _.find(team.players, (x) -> x.active)
      dot = _.find(player.dots, (x) -> x.active)
      {team, player, dot}

    _fire: (move) ->
      active = @_getActive()
      return unless move.agentId == active.player.id

      compiledFunction = math.compile(move.expression)

      flip = if active.dot.x > 0 then -1 else 1

      @state.fn = {
        expression: move.expression,
        origin: {x: active.dot.x, y: active.dot.y},
        evaluate: (x) -> compiledFunction.eval(x: flip*(x - active.dot.x)) - compiledFunction.eval(x: 0) + active.dot.y,
        startTime: @state.time
      }

    _processCollisions: ->
      endFunction = =>
        delete @state.fn
        @_advanceTurn()
        @state.turnTime = @TURN_TIME
        @state.updated = true

      flip = if @state.fn.origin.x > 0 then -1 else 1
      x = @state.fn.origin.x + flip*@FN_ANIMATION_SPEED*(@state.time - @state.fn.startTime)
      y = @state.fn.evaluate(x)

      active = @_getActive()
      for team in @state.teams
        for player in team.players
          for dot, index in player.dots
            if dot.alive and dot != active.dot and @_dist({x,y}, dot) < @DOT_RADIUS
              player.dots[index].alive = false
              @state.updated = true

      for obstacle in @state.obstacles
        
        if @_dist({x,y}, obstacle) < obstacle.radius and 
           @state.antiobstacles.every((ao) => @_dist({x,y}, ao) > @ANTIOBSTACLE_RADIUS)
          
          @state.antiobstacles.push({x,y})
          endFunction()

      unless -@X_MAX <= x <= @X_MAX and 
             -@Y_MAX <= y <= @Y_MAX

        endFunction()

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
      _.extend(@data, currentTime: Math.round(Date.now()))
      @subscriberCallbacks[subscriberId](@data)

    # Start animating, calling callback with a game state object every frame.
    startAnimatingForPlayer: (playerId, callback) ->
      animate = (t) =>
        @playbackTime += Math.round(t - @lastFrameTime)
        @lastFrameTime = t

        @generateStateAtTimeForPlayer(@playbackTime, playerId)
        if @state.updated
          console.log 'sending callback'
          callback(@state)
          @state.updated = false

        @animationRequestID = requestAnimationFrame(animate)
      @animationRequestID = requestAnimationFrame(animate)

    stopAnimating: ->
      cancelAnimationFrame(@animationRequestID)
      @animationRequestID = null