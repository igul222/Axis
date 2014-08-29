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
  # for i in [1..50]
    # t++
    # game.pushMove(Game.fire('0'), 2, t += 1000*30)
    # game.pushMove(Game.start(2), null, t++)

  # game.pushMove(Game.fire('0'), 1, t)
#  game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)
  # game.pushMovame.fire('0'), 1, t++)
  # game.pushMove(Game.fire('0'), 1, t++)

  # game.pushMove(Game.fire('0'), 2, t += 1000*30)
  # game.pushMove(Game.fire('0'), 1, t += 1000*30)
  # game.pushMove(Game.fire('0'), 2, t += 1000*30)
  # game.pushMove(Game.fire('0'), 1, t += 1000*30)
  # game.pushMove(Game.fire('0'), 2, t += 1000*30)
  # game.pushMove(Game.fire('0'), 1, t += 1000*30)
  # game.pushMove(Game.fire('0'), 2, t += 1000*30)

  # game.state.nextMoveTime = 0

  console.log 'testing...'

  t0 = Date.now()

  # Used to take 261ms
  game.generateStateAtTimeForPlayer(t += 1000*60*60, null)


  dt = Date.now() - t0
  times.push(dt)

console.log JSON.stringify(_.sortBy(times))