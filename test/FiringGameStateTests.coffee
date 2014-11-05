assert = require('assert')
sinon = require('sinon')

TypingFunctionGameState = require('../shared/TypingFunctionGameState')
FiringGameState = require('../shared/FiringGameState')
StartedGameState = require('../shared/StartedGameState')
FinishedGameState = require('../shared/FinishedGameState')
GameState = require('../shared/GameState')
Moves = require('../shared/Moves')
Geometry = require('../shared/Geometry')

describe 'FiringGameState', ->

  state = null

  beforeEach ->
    state = GameState.new(0.5)
      .handleMove(Moves.addPlayer(1))
      .handleMove(Moves.addPlayer(2))
    move = Moves.start()
    move.agentId = 1
    state = state.handleMove(move)
    move = Moves.fire('x')
    move.agentId = 1
    state = state.handleMove(move)

  describe 'fn object', ->

    it 'should have an expression', ->
      assert state.fn.expression == 'x'

    it 'should have an origin at the active dot', ->
      assert state.fn.origin.x == state.players.active().dot.x
      assert state.fn.origin.y == state.players.active().dot.y

    it 'should have a flip value of 1 for a player on team 1', ->
      assert state.fn.flip == 1

    it 'should have a working evaluate function', ->
      assert state.fn.evaluate(state.fn.origin.x) == state.fn.origin.y
      assert state.fn.evaluate(state.fn.origin.x + 1) == state.fn.origin.y + 1

    it 'should have an x value that starts at the origin', ->
      assert state.fn.x == state.fn.origin.x

  describe 'tick', ->

    it 'should increase fn.x if flip==1', ->
      oldX = state.fn.x
      state = state.tick()
      assert state.fn.x > oldX

    it "should not kill the firing player's dots when fn intersects with them", ->
      state = state.tick()
      assert state.players.teams[0].players[0].dots[0].alive == true

    it "should advance turn when it goes out of bounds", ->
      state.fn.x = StartedGameState.XMax + 1

      sinon.spy(state.players, 'advance')
      state = state.tick()
      assert state.players.advance.called
      assert state instanceof TypingFunctionGameState

    describe "when intersecting other players' dots", ->
      beforeEach ->
       state.players.teams[1].players[0].dots[0].x = state.fn.origin.x
       state.players.teams[1].players[0].dots[0].y = state.fn.origin.y

      it "should kill the dots", ->
        state = state.tick()
        assert state.players.teams[1].players[0].dots[0].alive == false

      it "should end the game if the game is over", ->
        state.players.teams[1].players[0].dots[1].x = state.fn.origin.x
        state.players.teams[1].players[0].dots[1].y = state.fn.origin.y
        state = state.tick()
        assert state instanceof FinishedGameState

      it "should not end the game if the game is not over", ->
        state = state.tick()
        assert state instanceof FiringGameState

    describe 'when it hits an obstacle', ->
      beforeEach ->
        # Position ourselves right in the center of an obstacle
        state.fn.x = state.obstacles._obstacles[0].x
        state.fn.evaluate = => state.obstacles._obstacles[0].y


      it "should blast a hole in the obstacle", ->
        blastFn = sinon.spy(state.obstacles, 'blast')
        state = state.tick()
        assert blastFn.called

      it "should advance turn", ->
        sinon.spy(state.players, 'advance')
        state = state.tick()
        assert state.players.advance.called
        assert state instanceof TypingFunctionGameState