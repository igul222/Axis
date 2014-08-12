React = require('react/addons')
Game = require('../../../shared/game.coffee')
Graph = require('./graph.cjsx')
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
        canvasWidth={800}
      />
      
      <p>Function:</p>
      <input type="text" valueLink={this.linkState('expression')} />
      <input type="submit" value="Fire" onClick={@fire} />

    </div>
)