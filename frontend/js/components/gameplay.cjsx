React = require('react/addons')
Graph = require('./graph.cjsx')
Game = require('../../../shared/game.coffee')
client = require('../client.coffee')

module.exports = React.createClass(
  mixins: [React.addons.LinkedStateMixin]
  getInitialState: ->
    {expression: 'sin(x)'}

  fire: ->
    client.pushMove(Game.fire(@state.expression))


  render: ->
    <div>
      <Graph
        gameState={@props.data.gameState}
        width={800}
        height={480}
        xrange={Game::BOARD_WIDTH}
        yrange={Game::BOARD_HEIGHT}
      />
      
      <p>Function:</p>
      <input type="text" valueLink={this.linkState('expression')} />
      <input type="submit" value="Fire" onClick={@fire} />

    </div>
)