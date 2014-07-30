React = require('react/addons')
Graph = require('./graph.cjsx')
Game = require('../../../shared/game.coffee')

module.exports = React.createClass(
  getInitialState: ->
    t: 0

  componentDidMount: ->
    requestAnimationFrame @tick

  tick: ->
    @setState t: @state.t + .005
    requestAnimationFrame @tick

  render: ->
    <Graph
      t={@state.t}
      functions={[
        {
          func: (x) -> Math.sin(x)
          origin:
            x: 0
            y: 0
        }
        {
          func: (x) -> 10
          origin:
            x: 0
            y: -5
        }
      ]}
      width={800}
      height={480}
      xrange={Game::BOARD_WIDTH}
      yrange={Game::BOARD_HEIGHT}
      />
)