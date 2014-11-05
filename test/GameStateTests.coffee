assert = require('assert')

GameState = require('../shared/GameState')
Players = require('../shared/Players')
Moves = require('../shared/Moves')

describe 'GameState', ->

  state = null

  beforeEach ->
    state = new GameState(0.5)

  it 'should have players', ->
    assert state.players instanceof Players

  it 'should have messages', ->
    assert state.messages instanceof Array

  it 'should set updated to true on init', ->
    assert state.updated == true

  it 'should set updated to true every 500ms', ->
    state.updated = false
    state.tick() for i in [1..500]
    assert state.updated == true

  it 'lets the server add players', ->
    state.handleMove(Moves.addPlayer(1))
    assert state.players.get(1)

  it 'does not let players add players', ->
    move = Moves.addPlayer(1)
    move.agentId = 1
    state.handleMove(move)
    assert !state.players.get(1)

  describe 'with a player', ->
    beforeEach ->
      state.handleMove(Moves.addPlayer(1))

    it 'lets the server remove players', ->
      state.handleMove(Moves.removePlayer(1))
      assert !state.players.get(1)

    it 'does not let players remove players', ->
      move = Moves.removePlayer(1)
      move.agentId = 1
      state.handleMove(move)
      assert state.players.get(1)

  it 'handles sendMessage from players', ->
    state.handleMove(Moves.addPlayer(1))

    move = Moves.sendMessage('hi')
    move.agentId = 1
    move.t = 1
    state.handleMove(move)

    assert state.messages[0].sender == 'Player 1'
    assert state.messages[0].text == 'hi'
    assert state.messages[0].time == 1