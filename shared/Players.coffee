_ = require('lodash')
Geometry = require('./Geometry.coffee')

module.exports = class Players
  @DotsPerPlayer: 2
  @DotRadius: 1
  @DotDistanceMin: 2

  constructor: ->
    @_started = false
    @_guests = {}
    @teams = [
        active: true
        players: []
      ,
        active: false
        players: []
    ]

  #####################
  # Getting player info
  #####################

  _players: ->
    _.flatten(_.pluck(@teams, 'players'))

  # Return the player with the given id, or undefined if none exists.
  get: (id) ->
    return _.find(@_players(), (p) -> p.id == id) or
           _.find(@_guests, (p) -> p.id == id)

  # Get the active team, player, and dot.
  active: ->
    @_active

  _updateActive: ->
    team = _.find(@teams, (x) -> x.active)
    player = _.find(team?.players, (x) -> x.active)
    dot = _.find(player?.dots, (x) -> x.active)
    @_active = {team, player, dot}

  isFlipped: (playerId) ->
    !! _.find(@teams[1].players, (p) -> p.id == playerId)

  isWinner: (playerId) ->
    return _.where(@get(playerId).dots, {alive: true}).length > 0

  getNextDotIndex: (playerId) ->
    for dot, index in @get(playerId).dots
      return index if dot.active and dot.alive
    return undefined

  ##########
  # Commands
  ##########

  add: (id) ->
    if @_started
      @_guests[id] =
        id: id
        name: 'Guest '+ (_.size(@_guests) + 1)
    else
      if @teams[0].players.length <= @teams[1].players.length
        team = @teams[0]
      else
        team = @teams[1]

      team.players.push
        id: id
        name: 'Player ' + (@_players().length + 1)
        nameChanged: false
        active: false
        dots: []

  remove: (id) ->
    for team in @teams
      team.players = _.reject(team.players, (p) -> p.id == id)

  gameStarted: (obstacles, rand, xMax, yMax) ->
    @_started = true

    # Keep track of generated dots to avoid generating two nearby dots
    dots = []

    for team, teamIndex in @teams
      hOffset = xMax * (teamIndex - 1)
      for player in team.players
        for i in [1..@constructor.DotsPerPlayer]
          loop

            point = Geometry.randomPoint(
              hOffset,        -yMax,
              hOffset + xMax,  yMax,
              rand
            )

            if dots.every((d) => Geometry.dist(point, d) > (2 * @constructor.DotRadius) + @constructor.DotDistanceMin) and 
               !obstacles.hitTest(point.x, point.y, @constructor.DotRadius)

              dot = {x: point.x, y: point.y, alive: true, active: false, expression: 'sin(x)'}

              dots.push(dot)
              player.dots.push(dot)
              break

    recursivelySetActive = (ary) ->
      return unless ary?
      ary[0].active = true
      for item in ary
        recursivelySetActive(item.players || item.dots || null)

    recursivelySetActive(@teams)
    @_updateActive()

  changeName: (id, name)->
    player = @get(id)
    player.name = name
    player.nameChanged = true


  kill: (id) ->
    for team in @teams
      for player in team.players
        if player.id == id
          for dot in player.dots
            dot.alive = false

  switchTeam: (id) ->
    for team, index in @teams
      for player in team.players
        if player.id == id
          newTeam = if index == 0 then @teams[1] else @teams[0]
          oldPlayer = player

    @remove(id)
    newTeam.players.push(oldPlayer)

  # Advance the game by one turn, updating team/player/dot active values
  # Returns true on success (i.e. we advanced the turn), false on failure (i.e. the game is over)
  advance: ->
    recursivelyAdvance = (ary) ->
      return unless ary?
      for item,i in ary
        if item.active
          item.active = false
          ary[(i+1) % ary.length].active = true
          recursivelyAdvance(item.players || item.dots || null)
          break

    advanceOneTurn = =>
      recursivelyAdvance(@teams)
      @_updateActive()

    advanceOneTurn()

    # If the new dot is dead, keep advancing.
    until @active().dot.alive
      advanceOneTurn()

  # Returns true if the game is over (i.e. no more players on one team)
  gameOver: ->
    @teams.some (t) ->
      _(t.players).pluck('dots').flatten().every((d) -> !d.alive)