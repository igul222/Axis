# agent = require('webkit-devtools-agent')
# agent.start()
GameState = require('./shared/GameState')
Moves = require('./shared/Moves')
_ = require('lodash')


setTimeout((->

  times = []
  for useless in [1..10]
    console.log 'testing...'
    t0 = Date.now()

    state = GameState.new(0.5)
      .handleMove(Moves.addPlayer(1))
      .handleMove(Moves.addPlayer(2))

    move = Moves.start()
    move.agentId = 1
    state = state.handleMove(move)

    for i in [1..50]
      move = Moves.fire('x')
      move.agentId = 1
      state = state.handleMove(move)

      for i in [1..(1000*30)]
        state = state.tick()

    dt = Date.now() - t0
    times.push(dt)

  console.log JSON.stringify(_.sortBy(times))
), 0)