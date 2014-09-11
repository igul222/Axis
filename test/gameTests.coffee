assert = require('assert')
Game = require('../shared/game.coffee')
helpers = require('./helpers.coffee')
_ = require('lodash')

describe 'Game', ->

  it 'should have a valid state object', ->
    game = new Game()
    assert game.state.started==false
    assert game.state.teams?.length == 2
    assert game.state.teams[0].players?.length == 0

  it 'should have valid "active team/player/dot" tree', ->
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

  it 'should add players to state', ->
    game = helpers.generateGame([Game.addPlayer(1, 'bob')])
    assert game.state.teams[0].players[0].id == 1
    assert game.state.teams[0].players[0].name == 'bob'

  it 'should remove players from state', ->
    game = helpers.generateGame([
      Game.addPlayer(1, 'bob'),
      _.merge(Game.removePlayer(1), agentId: 1)
    ])

    assert game.state.teams[0].players.length == 0
    assert game.state.teams[1].players.length == 0

  it 'should delete dots when a function intersects them', ->
    game = helpers.generateGame([
      Game.addPlayer(1, 'ishaan'),
      Game.addPlayer(2, 'zain'),
      Game.start(2),
      Game.setDotLocation({team: 0, player: 0, dot: 0}, {x: -1, y: 0}),
      Game.setDotLocation({team: 1, player: 0, dot: 0}, {x: 1, y: 0})
    ])

    # Fire
    game.pushMove(Game.fire('0'), 1, 5)
    game.generateStateAtTimeForPlayer(5, null)
    
    # Fast-forward to when the function has moved one unit 
    game.generateStateAtTimeForPlayer(game.state.time + (1 / Game::FN_ANIMATION_SPEED), null)

    assert game.state.teams[1].players[0].dots[0].alive

    # Fast-forward another unit
    game.generateStateAtTimeForPlayer(game.state.time + (1 / Game::FN_ANIMATION_SPEED), null)

    assert !game.state.teams[1].players[0].dots[0].alive

  describe '(turn advancement)', ->

    it 'should decrement turnTime on each tick', ->
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2)
      ])

      oldTime = game.state.turnTime
      game.generateStateAtTimeForPlayer(game.state.time + 1)
      assert game.state.turnTime == oldTime - 1

    it 'should advance turns when turnTime reaches zero', ->
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

    it 'should not decrement turnTime while firing', ->
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2),
        _.assign(Game.fire('sin(x)'), agentId: 1)
      ])

      oldTime = game.state.turnTime
      game.generateStateAtTimeForPlayer(game.state.time + 2)

      assert game.state.turnTime == oldTime

    it 'should advance turns after firing', ->
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

    it 'should send messages from any player', ->
      game = helpers.generateGame([
        Game.addPlayer(1, 'ishaan'),
        Game.addPlayer(2, 'zain'),
        Game.start(2),
        _.assign(Game.sendMessage('Hello!!'), agentId: 1)
      ])