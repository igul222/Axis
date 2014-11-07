Moves = require('../../../shared/Moves.coffee')
Graph = require('./graph.cjsx')
play = require('play-audio')
StartedGameState = require('../../../shared/StartedGameState.coffee')

TypingFunctionGameState = require('../../../shared/TypingFunctionGameState.coffee')

module.exports = React.createClass(
  displayName: 'FinishedScreen'
  mixins: [React.addons.LinkedStateMixin]

  endStatus: ->
    status = if @props.data.gameState.players.winner(@props.data.playerId) then "YOU WIN!" else "YOU LOSE."
    console.log(status)
    return status

  joinPublicGame: (e) ->
    e.preventDefault()
    r = new XMLHttpRequest()
    r.open('POST', '/joinPublicGame', true)
    r.onreadystatechange = ->
      return unless r.readyState == 4 and r.status == 200
      page('/games/'+ r.responseText)
    r.send()

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
      <div id='canvas-wrapper'>
        <div id="finished-screen-text">
          {@endStatus()}
        </div>
      </div>

      <form id='controls'>

        <div id='time-remaining-wrapper'>
          <div id='time-remaining'>{ turnTime }</div>
        </div>

        <div id='expression-wrapper'>
          <div id='expression'>
            <input type = "text" value = "press any key to play again" />
            <div id='lcd-background'>ஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏஏ</div>
          </div>
        </div>

        <div id='fire-wrapper'>
          <div className='huge-button-wrapper'>
            <input
              className='huge black button'
              value='FIRE'
            />
          </div>
        </div>

      </form>
    </div>
)