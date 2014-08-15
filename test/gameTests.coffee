assert = require('assert')
Game = require('../shared/game.coffee')
helpers = require('./helpers.coffee')
_ = require('lodash')

describe 'Game', ->

  describe '#generateStateAtTimeForPlayer(t, playerId)', =>

    it 'should return a state object', =>
      state = new Game().generateStateAtTimeForPlayer(1, null)
      assert state.time==1
      assert state.started==false
      assert state.teams?.length == 2
      assert state.teams[0].players?.length == 0

    it 'should decrease turn time', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2)
      ])

      assert game.state.turnTime == 60000
      game.generateStateAtTimeForPlayer(game.state.time + 1)
      assert game.state.turnTime == 59999

    it 'should advance turns when turn time runs out', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2)
      ])

      game.generateStateAtTimeForPlayer(game.state.time + 60000)

      assert game.state.turnTime == 60000
      assert game.state.teams[1].active
      assert game.state.teams[1].players[0].active
      assert game.state.teams[1].players[0].dots[0].active

    it 'should not decrement turn time while firing', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2),
        _.assign(Game.fire('sin(x)'), agentId: 1)
      ])

      oldTime = game.state.turnTime
      game.generateStateAtTimeForPlayer(game.state.time + 1)
      assert game.state.turnTime == oldTime

    it 'should advance turns after firing', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2),
        _.assign(Game.fire('sin(x)'), agentId: 1)
      ])

      while game.state.fn
        game.generateStateAtTimeForPlayer(game.state.time + 1)

      assert game.state.turnTime == 60000
      assert game.state.teams[1].active
      assert game.state.teams[1].players[0].active
      assert game.state.teams[1].players[0].dots[0].active

    it 'should start with a valid active state tree', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'team1p1'),
        Game.addPlayer(2, 'team2p1'),
        Game.addPlayer(3, 'team1p2'),
        Game.addPlayer(4, 'team2p2'),
        Game.start(1)
      ])

      assert game.state.teams[0].active
      assert !game.state.teams[1].active
      for team in game.state.teams
        assert team.players[0].active
        assert !team.players[1].active
        for player in team.players
          assert player.dots[0].active
          assert !player.dots[1].active

  describe 'adding players', =>

    it 'should add a player to game state', =>
      game = helpers.generateGame([Game.addPlayer(1, 'bob')])
      assert game.state.teams[0].players[0].id == 1
      assert game.state.teams[0].players[0].name == 'bob'

  describe '#_processCollisions', =>

    it 'should delete dots at f(state.time)', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain')
        Game.start(2),
      ])

      game.state.teams[0].players[0].dots[0].x = -1
      game.state.teams[0].players[0].dots[0].y = 0

      game.state.teams[1].players[0].dots[0].x = 1
      game.state.teams[1].players[0].dots[0].y = 0

      game.pushMove(Game.fire('0'), 1, 3)
      game.generateStateAtTimeForPlayer(3, null)

      game.state.time += 1 / Game::FN_ANIMATION_SPEED
      game._processCollisions()

      assert game.state.teams[1].players[0].dots[0].alive

      game.state.time += 1 / Game::FN_ANIMATION_SPEED
      game._processCollisions()

      assert !game.state.teams[1].players[0].dots[0].alive