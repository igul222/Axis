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
      <div className='row'>
        <div className='col-sm-12'>
          <Graph gameState={gameState} />
        </div>
      </div>

      <div id='controls' className='row'>
        <div className='col-sm-9 col-md-10'>
          <form>
            <input type="text" valueLink={this.linkState('expression')} />
            <input
              className='button black'
              type='submit'
              value='Fire'
              onClick={@fire}
              disabled={gameState.fn or gameState.active.player?.id != gameState.playerId}
            />
          </form>
        </div>

        <div className='col-sm-3 col-md-2'>
          <div id='time-remaining'>{ turnTime }</div>
        </div>
      </div>
    </div>

    # <div>

    #   <p>Function:</p>
    #   <form>
    #     <input type="text" valueLink={this.linkState('expression')} />
    #     <input
    #       className='button black'
    #       type='submit'
    #       value='Fire'
    #       onClick={@fire}
    #       disabled={state.fn or state.active.player?.id != state.playerId}
    #     />
    #   </form>

    #   <p id="turn-time">Turn time: {state.turnTime / 1000}</p>

    # </div>
)