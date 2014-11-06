Moves = require('../../../shared/Moves.coffee')
validateExpression = require('../../../shared/validateExpression.coffee')
Graph = require('./graph.cjsx')

TypingFunctionGameState = require('../../../shared/TypingFunctionGameState.coffee')

module.exports = React.createClass(
  displayName: 'Gameplay'
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    expression: 'sin(x)'
    validatesExpression: false

  expressionBlurred: (e) ->
    this.setState(validatesExpression: true)

  canFire: ->
    gameState = @props.data.gameState

    gameState instanceof TypingFunctionGameState and
    gameState.players.active().player.id == @props.data.playerId and
    validateExpression(@state.expression)

  fire: (evt) ->
    @props.pushMove(Moves.fire(@state.expression))
    evt.preventDefault()

  render: ->
    gameState = @props.data.gameState
    cx = React.addons.classSet

    turnTime = Math.round(gameState.turnTime / 100)
    if turnTime < 10
      if turnTime > 0
        turnTime = '0' + turnTime
      else
        turnTime = '--'

    <div>
      <Graph data={@props.data} />

      <form id='controls'>

        <div id='time-remaining-wrapper'>
          <div id='time-remaining'>{ turnTime }</div>
        </div>

        <div id='expression-wrapper' className={cx(
          'has-error':this.state.validatesExpression && !validateExpression(@state.expression),
          'has-success':this.state.validatesExpression && validateExpression(@state.expression)
          )}>
          <div id='expression'>
            <input type='text' valueLink={@linkState('expression')} />
            <div id='lcd-background'>ஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏ</div>
          </div>
        </div>

        <div id='fire-wrapper'>
          <div className='huge-button-wrapper'>
            <input
              className='huge black button'
              type='submit'
              value='FIRE'
              onClick={@fire}
              disabled={!@canFire()}
            />
          </div>
        </div>

      </form>
    </div>
)