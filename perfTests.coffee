Game = require('./shared/game.coffee')
helpers = require('./test/helpers.coffee')
_ = require('lodash')

times = []
for useless in [1..10]

  game = helpers.generateGame([
    Game.addPlayer(1, 'ishaan'),
    Game.addPlayer(2, 'zain'),
    Game.start(2),
  ])

  t = game.state.time + 1
  for i in [1..50]
    game.pushMove(Game.fire('0'), 2, t += 1000*30)

  console.log 'testing...'

  t0 = Date.now()

  game.generateStateAtTimeForPlayer(t += 1000*60*60, null)

  dt = Date.now() - t0

  times.push(dt)

console.log JSON.stringify(_.sortBy(times))