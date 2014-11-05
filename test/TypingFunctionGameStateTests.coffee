assert = require('assert')
sinon = require('sinon')

TypingFunctionGameState = require('../shared/TypingFunctionGameState')
FiringGameState = require('../shared/FiringGameState')
GameState = require('../shared/GameState')
Moves = require('../shared/Moves')

describe 'TypingFunctionGameState', ->

  state = null

  beforeEach ->
    state = GameState.new(0.5)
      .handleMove(Moves.addPlayer(1))
      .handleMove(Moves.addPlayer(2))
    move = Moves.start()
    move.agentId = 1
    state = state.handleMove(move)

  it 'should have a turn time with an initial value', ->
    assert state.turnTime == TypingFunctionGameState.TurnTime

  it 'should decrement the turn time every tick', ->
    oldTime = state.turnTime
    state = state.tick()
    assert state.turnTime == oldTime - 1

  describe 'when turn time runs out', ->
    beforeEach ->
      state = state.tick() until state.turnTime == 1

    it 'should advance turns', ->
      sinon.spy(state.players, 'advance')
      state = state.tick()
      assert state.players.advance.called

    it 'should reset the turn time', ->
      state = state.tick()
      assert state.turnTime == TypingFunctionGameState.TurnTime

  describe 'fire', ->

    it 'should fire valid functions from the active player', ->
      move = Moves.fire('x^2')
      move.agentId = 1
      state = state.handleMove(move)
      assert state instanceof FiringGameState

    it 'should not fire invalid functions', ->
      move = Moves.fire('(unmatched paren')
      move.agentId = 1
      state = state.handleMove(move)
      assert state instanceof TypingFunctionGameState


    it 'should not fire functions from players other than the active one', ->
      move = Moves.fire('(unmatched paren')
      move.agentId = 2
      state = state.handleMove(move)
      assert state instanceof TypingFunctionGameState