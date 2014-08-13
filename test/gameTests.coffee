assert = require('assert')
Game = require('../shared/game.coffee')
helpers = require('./helpers.coffee')

describe 'Game', ->

  describe '#generateStateAtTimeForPlayer(t, playerId)', =>

    it 'should return a state object', =>
      state = new Game().generateStateAtTimeForPlayer(10, null)
      assert state.time
      assert state.started==false
      assert state.teams?.length == 2
      assert state.teams[0].players?.length == 0

  describe 'adding players', =>

    it 'should add a player to game state', =>
      game = helpers.generateGame([Game.addPlayer(1, 'bob')])

      assert game.state.teams[0].players[0].id == 1
      assert game.state.teams[0].players[0].name == 'bob'

  describe '#_stepFunction', =>

    it 'should delete dots between f(state.time - dt) and f(state.time)', =>
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
      game._stepFunction(game.state, 1 / Game::FN_ANIMATION_SPEED)

      assert game.state.teams[1].players[0].dots[0].alive

      game.state.time += 2 / Game::FN_ANIMATION_SPEED
      game._stepFunction(game.state, 2 / Game::FN_ANIMATION_SPEED)

      assert !game.state.teams[1].players[0].dots[0].alive