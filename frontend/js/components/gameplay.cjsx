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
      gameState={@props.data.gameState}
      width={800}
      height={480}
      xrange={Game::BOARD_WIDTH}
      yrange={Game::BOARD_HEIGHT}
    />
)