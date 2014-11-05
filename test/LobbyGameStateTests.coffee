assert = require('assert')

LobbyGameState = require('../shared/LobbyGameState')
StartedGameState = require('../shared/StartedGameState')
Moves = require('../shared/Moves')

describe 'LobbyGameState', ->

  state = null

  beforeEach ->
    state = LobbyGameState.new(0.5)

  it 'with two players, starts the game', ->
    state.handleMove(Moves.addPlayer(1))
    state.handleMove(Moves.addPlayer(2))

    move = Moves.start()
    move.agentId = 1

    nextState = state.handleMove(move)
    assert nextState instanceof StartedGameState

  it 'with one player, does not start the game', ->
    state.handleMove(Moves.addPlayer(1))

    move = Moves.start()
    move.agentId = 1

    nextState = state.handleMove(move)
    assert !(nextState instanceof StartedGameState)