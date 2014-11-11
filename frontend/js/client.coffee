# The game's socket.io client and central data store

GameStateGenerator = require('../../shared/GameStateGenerator.coffee')

module.exports = class ClientSubscription
  
  constructor: (@socket, @gameId, @callback) ->
    _receivedData = (data) =>
      window.cancelAnimationFrame(@animationRequest) if @animationRequest

      stateGenerator = new GameStateGenerator(data)

      @animationRequest = window.requestAnimationFrame (startTimestamp) =>
        startTimestamp = startTimestamp / 10

        animate = (timestamp) =>
          playbackTime = Math.round(data.currentTime + (timestamp / 10) - startTimestamp)
          gameState = stateGenerator.generateAtTime(playbackTime)
          if gameState.updated
            gameState.updated = false
            @_update(gameState)
          @animationRequest = window.requestAnimationFrame(animate)

        @animationRequest = window.requestAnimationFrame(animate)

    @socket.on('data', _receivedData)
    @socket.emit('subscribe', @gameId)

  pushMove: (move) ->
    @socket.emit('pushMove', move)

  unsubscribe: ->
    @socket.disconnect()
    window.cancelAnimationFrame(@animationRequest) if @animationRequest

  _update: (gameState) ->
    @callback(gameState: gameState, playerId: @socket.io.engine.id)