React = require('react/addons')
Game = require('../../../shared/game.coffee')
Graph = require('./graph.cjsx')
client = require('../client.coffee')

module.exports = React.createClass(
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    {expression: 'sin(x)'}

  fire: (evt) ->
    client.pushMove(Game.fire(@state.expression))
    evt.preventDefault()

  render: ->
    <div>
      <Graph
        gameState={@props.data.gameState}
      />
      
      <p>Function:</p>
      <form>
        <input type="text" valueLink={this.linkState('expression')} />
        <input className='button black' type="submit" value="Fire" onClick={@fire} />
      </form>

      <p id="turn-time">Turn time: {@props.data.gameState.turnTime / 1000}</p>

    </div>
)