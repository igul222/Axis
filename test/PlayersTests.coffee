assert = require('assert')
seed = require('seed-random')

Players = require('../shared/Players')

describe 'Players', ->

  players = null

  beforeEach ->
    players = new Players()
    players.add(1)
    players.add(2)

  describe 'when not started', ->

    it 'should get players', ->
      assert players.get(1)

    it 'should return undefined when attempting to get an invalid player', ->
      assert players.get(3) == undefined

    it 'adds players to the team with fewer players', ->
      assert players.teams[0].players[0].id == 1
      assert players.teams[1].players[0].id == 2

    it 'assigns players default names', ->
      assert players.teams[0].players[0].name == 'Player 1'
      assert players.teams[1].players[0].name == 'Player 2'

    it 'removes players from state', ->
      players.remove(1)
      assert players.teams[0].players.length == 0

  describe 'when started', ->
    beforeEach ->
      obstaclesMock =
        hitTest: -> false
      players.gameStarted(obstaclesMock, seed(0.5), 25, 15)

    it 'adds players as guests', ->
      players.add(3)
      assert players.get(3)

    it 'should generate dots for each player', ->
      assert players.teams[0].players[0].dots.length = Players.DotsPerPlayer
      assert players.teams[1].players[0].dots.length = Players.DotsPerPlayer

    it 'should have an active team/player/dot', ->
      assert players.active().team == players.teams[0]
      assert players.active().player == players.teams[0].players[0]
      assert players.active().dot == players.teams[0].players[0].dots[0]

    it 'should kill players', ->
      players.kill(1)
      assert players.teams[0].players[0].dots[0].alive == false
      assert players.teams[0].players[0].dots[1].alive == false

    it "determines whether a player's screen is flipped", ->
      assert players.isFlipped(1) == false
      assert players.isFlipped(2) == true

    describe 'advancing turns', ->

      it 'should advance to the next turn', ->
        players.advance()
        assert players.active().team == players.teams[1]
        assert players.active().player == players.teams[1].players[0]
        assert players.active().dot == players.teams[1].players[0].dots[0]

      it 'should skip dead dots', ->
        players.teams[1].players[0].dots[0].alive = false
        players.advance()
        assert players.active().team == players.teams[0]
        assert players.active().player == players.teams[0].players[0]
        assert players.active().dot == players.teams[0].players[0].dots[1]

    it 'indicates that the game is not over', ->
      assert players.gameOver() == false

    describe.only 'when finished', ->
      beforeEach ->
        players.kill(1)

      it 'indicates that the game is over', ->
        assert players.gameOver() == true

      it 'identifies winning players', ->
        assert players.isWinner(2) == true

      it 'identifies non-winning players', ->
        assert players.isWinner(1) == false