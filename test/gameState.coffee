Game = require('../shared/game.coffee')
_ = require('lodash')

game = new Game()

game.replaceData(
  currentTime: 0,
  rand: 0.5,
  moves: [_.assign(Game.addPlayer(1, 'bob'), {t: 1, agentId: null})]
)

state = game.generateStateAtTimeForPlayer(2, null)

module.exports = state