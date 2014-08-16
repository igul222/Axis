assert = require('assert')
Game = require('../../shared/game.coffee')
helpers = require('../helpers.coffee')
_ = require('lodash')

module.exports = ->
  describe '(turn advancement)', ->

    it 'should decrement turnTime on each tick', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2)
      ])

      oldTime = game.state.turnTime
      game.generateStateAtTimeForPlayer(game.state.time + 1)
      assert game.state.turnTime == oldTime - 1

    it 'should advance turns when turnTime reaches zero', =>
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2)
      ])

      game.state.turnTime = 1
      game.generateStateAtTimeForPlayer(game.state.time + 1)

      assert game.state.turnTime == Game::TURN_TIME
      assert game.state.teams[1].active
      assert game.state.teams[1].players[0].active
      assert game.state.teams[1].players[0].dots[0].active

    it 'should not decrement turnTime while firing', =>
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