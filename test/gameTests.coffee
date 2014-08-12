Game = require('../shared/game.coffee')
assert = require('assert')
_ = require('lodash')

describe 'Game', ->

  beforeEach => 
    @game = new Game()


  describe '#generateStateAtTimeForPlayer(t, playerId)', =>

    it 'should return a state object', =>
      assert @game.generateStateAtTimeForPlayer(10, null).teams


  describe 'adding players', =>

    it 'should add a player to game state', =>
      @game.replaceData(
        currentTime: 0,
        rand: 0.5,
        moves: [_.assign(Game.addPlayer(1, 'bob'), {t: 1, agentId: null})]
      )

      state = @game.generateStateAtTimeForPlayer(2, null)
      assert state.teams[0].players[0].name == 'bob'