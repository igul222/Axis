Game = require('./shared/game.coffee')
helpers = require('./test/helpers.coffee')
_ = require('lodash')

times = []
for useless in [1..10]

  console.log 'initializing game...'

  game = helpers.generateGame([
    Game.addPlayer(1, 'ishaan'),
    Game.addPlayer(2, 'zain'),
    Game.start(2),
  ])

  console.log 'testing...'

  t0 = Date.now()

  game._generateObstaclePaths()

  dt = Date.now() - t0

  times.push(dt)

console.log JSON.stringify(_.sortBy(times))