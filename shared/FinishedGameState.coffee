GameState = require('./GameState.coffee')

module.exports = class FinishedGameState extends GameState

  @new: (old) ->
    new FinishedGameState(old)

  constructor: (old) ->
    super(old)