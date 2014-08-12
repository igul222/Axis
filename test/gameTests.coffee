Game = require('../shared/game.coffee')
assert = require('assert')
_ = require('lodash')

describe 'Game', ->

  beforeEach => 
    @game = new Game()

  describe '#generateStateAtTimeForPlayer(t, playerId)', =>

    it 'should return a state object', =>
      assert @game.generateStateAtTimeForPlayer(10, null).teams

    it 'should add a player in the moves array', =>
      @game.replaceData(
        currentTime: 100,
        rand: 0.5,
        moves: [_.assign(Game.addPlayer(1, 'bob'), {t: 100, agentId: null})]
      )

      state = @game.generateStateAtTimeForPlayer(105, null)
      assert state.teams[0].players[0].name == 'bob'