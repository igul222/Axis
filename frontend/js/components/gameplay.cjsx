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
    state = @props.data.gameState
    <div>
      <div className='row'>
        <div className='col-sm-12'>
          <Graph gameState={state} />
        </div>
      </div>

      <div className='row'>
        <div className='col-sm-10'>
          <form>
            <input type="text" valueLink={this.linkState('expression')} />
            <input
              className='button black'
              type='submit'
              value='Fire'
              onClick={@fire}
              disabled={state.fn or state.active.player?.id != state.playerId}
            />
          </form>
        </div>

        <div className='col-sm-2'>
          {state.turnTime / 10}
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