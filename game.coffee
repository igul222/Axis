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
      @generateDots()
      console.log(_.sample(_.sample(@state.teams).players).dots)
      @_updateAll()

    #random xy coordinate within given rectangle (origin and size)
    randomPointInRect: (x0, y0, width, height) ->
      point =
        x: Math.floor(Math.random()*width)+x0
        y: Math.floor(Math.random()*height)+y0
      point

    # Generate random positions for beginning gameplay
    generateDots:->
      randomPointInRect = @randomPointInRect

      #fixed width and height, but should come from state
      height = 800
      width = 800

      _.each(@state.teams, (team, teamindex, teams) ->
        #area of the graph, divided into rectangles of the same height
        subdivheight = (height/team.players.length)
        subdivwidth = (width/2)

        _.each(team.players, 
          (player, playerindex, players) ->
            for dot in [0...Math.floor(6/team.players.length)]
              player.dots.push(randomPointInRect(subdivwidth*teamindex, playerindex*subdivheight, subdivwidth, subdivheight))
        )
      )
    
    advanceTurn: ->
      #keep track of which states have been switched already, so that when one is switched, it can be broken out of
      switchedStates = 
        team: false
        player: false
        dot: false

      #loop through teams, so long as teams haven't been switched yet, switch when the active one is found
      _.each(@state.teams, (team, teamindex, teams)->
        if(!switchedStates.team)
          if(team.active)
            team.active = false
            switchedStates.team = true
            
            #if the active team is the last team, then reset to first team
            if(teamindex == teams.length-1) #parameters: index, list
              @state.team[0].active = true
            else
              @state.team[teamindex+1].active = true
          
          _.each(team.players, (player, playerindex, players)->
            if(!switchedStates.player)
              if(player.active)
                player.active = false
                switchedStates.player = true

                #if the active is last, then reset to first
                if(playerindex == players.length-1)
                  players[0].active = true
                else
                  players[playerindex+1].active = true

              _.each(player.dots, (dot, dotindex, dots)->
                if(!switchedStates.dot)
                  if(dot.active)
                    dot.active = false
                    switchedStates.dot = true

                    #if active is last, reset to first
                    if(dotindex == dots.length-1)
                      dots[0].active = true
                    else
                      dots[dotindex+1].active = true
              )
          )
      )

    advance:(index, list)->
      if(index == list.length-1) #parameters: index, list
        list[0].active = true
      else
        list[index+1].active = true
       
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