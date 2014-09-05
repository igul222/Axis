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
    gameState = @props.data.gameState

    turnTime = Math.round(gameState.turnTime / 1000)
    if turnTime < 10
      if turnTime > 0
        turnTime = '0' + turnTime
      else
        turnTime = '--'



    <div>
      <Graph gameState={gameState} />

      <form id='controls'>

        <div id='time-remaining-wrapper'>
          <div id='time-remaining'>{ turnTime }</div>
        </div>

        <div id='expression-wrapper'>
          <div id='expression'>
            <input type='text' valueLink={this.linkState('expression')} />
            <div id='lcd-background'>ஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏ</div>
          </div>
        </div>

        <div id='fire-wrapper'>
          <input
            className='huge black button'
            type='submit'
            value='FIRE'
            onClick={@fire}
            disabled={gameState.fn or gameState.active.player?.id != gameState.playerId}
          />
        </div>

      </form>

    </div>
)