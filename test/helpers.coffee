Game  = require('../shared/game.coffee')
_     = require('lodash')
jsdom = require('jsdom').jsdom

module.exports = 
  generateGame: (moves = []) ->
    for move, i in moves
      moves[i] = _.defaults(move, {t: i, agentId: null})

    game = new Game()

    game.replaceData(
      currentTime: moves.length,
      rand: 0.5,
      moves: moves
    )

    game.generateStateAtTimeForPlayer(moves.length - 1, null)
    return game

  initDOM: ->
    _.assign(global, require('request-animation-frame'))

    global.window = jsdom().createWindow('<html><body></body></html>')
    global.document = window.document
    global.navigator = window.navigator

  cleanDOM: ->
    delete global.window
    delete global.document
    delete global.navigator