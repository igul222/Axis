Moves = require('../../../shared/Moves.coffee')
validateExpression = require('../../../shared/validateExpression.coffee')
Graph = require('./graph.cjsx')
play = require('play-audio')

TypingFunctionGameState = require('../../../shared/TypingFunctionGameState.coffee')

module.exports = React.createClass(
  displayName: 'Gameplay'
  mixins: [React.addons.LinkedStateMixin]

  getInitialState: ->
    expression: 'sin(x)'

  componentDidMount: ->
    @sounds = 
      fire: play('/ping.wav').preload()
      obstacleHit: play('/explosion-1.mp3').preload()
      playerHit: play('/explosion-4.mp3').preload()
    @playedSounds = {}

  componentDidUpdate: ->
    @playSounds()

  playSounds: ->
    sound = @props.data.gameState.sound
    if sound and !@playedSounds[sound.id]
      @playedSounds[sound.id] = true
      @sounds[sound.name].play()

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

        <div id='expression-wrapper'>
          <div id='expression'>
            <input type='text' valueLink={@linkState('expression')} />
            <div id='lcd-background'>ĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉ</div>
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