assert = require('assert')
sinon = require('sinon')

GameState = require('../shared/GameState')
StartedGameState = require('../shared/StartedGameState')
FinishedGameState = require('../shared/FinishedGameState')
Moves = require('../shared/Moves')
Obstacles = require('../shared/Obstacles')
Players = require('../shared/Players')

describe 'StartedGameState', ->
  
  state = null

  beforeEach -> 
    state = GameState.new(0.5)
      .handleMove(Moves.addPlayer(1))
      .handleMove(Moves.addPlayer(2))
      .handleMove(Moves.addPlayer(3))
    move = Moves.start()
    move.agentId = 1
    state = state.handleMove(move)


  it 'should have obstacles', ->
    assert state.obstacles instanceof Obstacles

  it 'should transition players object to started', ->
    assert state.players.teams[0].players[0].dots.length == Players.DotsPerPlayer

  it 'plays sounds'

  it 'deletes sounds after they finish'

  describe 'removePlayer', ->

    it 'should let players kill themselves', ->
      sinon.spy(state.players, 'kill')
      move = Moves.removePlayer(1)
      move.agentId = 1
      state = state.handleMove(move)
      assert state.players.kill.calledWith(1)

    it 'should not let players kill other players', ->
      sinon.spy(state.players, 'kill')
      move = Moves.removePlayer(1)
      move.agentId = 2
      state = state.handleMove(move)
      assert state.players.kill.notCalled

    it 'should advance turns if the killed player was active', ->
      sinon.spy(state.players, 'advance')
      move = Moves.removePlayer(1)
      move.agentId = 1
      state = state.handleMove(move)
      assert state.players.active().player == state.players.get(2)

    it 'should end the game if the game is over', ->
      move = Moves.removePlayer(2)
      move.agentId = 2
      state = state.handleMove(move)

      assert state instanceof FinishedGameState

    it 'should not end the game if the game is not over', ->
      move = Moves.removePlayer(1)
      move.agentId = 1
      state = state.handleMove(move)

      assert state instanceof StartedGameState