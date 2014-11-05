assert = require('assert')
sinon = require('sinon')

Client = require('../frontend/js/Client')
Game = require('../backend/Game')
Moves = require('../shared/Moves')

describe.skip 'Client', -> 

  socket = null
  callback = null
  subscription = null

  beforeEach ->
    socket =
      on: sinon.spy()
      emit: sinon.spy()
      removeListener: sinon.spy()
      disconnect: sinon.spy()
      io: {engine: {id: 1}}
    callback = sinon.spy()
    subscription = new ClientSubscription(socket, 1, callback)

  it 'emits a subscribe message', ->
    assert socket.emit.args[0][0] == 'subscribe'
    assert socket.emit.args[0][1] == 1

  it 'handles data from the server', ->
    assert socket.on.args[0][0] == 'data'

  it 'pushes a move to a game', ->
    subscription.pushMove('move')
    assert socket.emit.args[1][0] == 'pushMove'
    assert socket.emit.args[1][1] == 'move'

  it 'unsubscribes from a game', ->
    subscription.unsubscribe()
    assert socket.disconnect.called

  describe 'when receiving data from the server', ->

    beforeEach ->
      GLOBAL.window = {}
      window.requestAnimationFrame = sinon.stub()
      window.requestAnimationFrame.returns(1)
      game = new Game()
      game.pushMove(Moves.addPlayer(1))
      socket.on.args[0][1](game)

    afterEach ->
      delete GLOBAL.window

    it 'schedules an animation frame', ->
      assert window.requestAnimationFrame.called

    describe 'on animation frame', ->

      beforeEach ->
        animate = window.requestAnimationFrame.args[0][0]
        animate(Date.now())

      it 'sends an update with a game state and player ID', ->
        assert callback.called
        assert callback.args[0][0].gameState
        assert callback.args[0][0].playerId

      it 'schedules another animation frame', ->
        assert window.requestAnimationFrame.called

      it 'on unsubscribe, cancels the scheduled animation frame', ->
        window.cancelAnimationFrame = sinon.spy()
        subscription.unsubscribe()
        assert window.cancelAnimationFrame.called