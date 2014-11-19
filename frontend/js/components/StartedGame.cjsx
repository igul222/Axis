play = require('play-audio')

Computer = require('./Computer.cjsx')
Graph = require('./Graph.cjsx')

Moves = require('../../../shared/Moves.coffee')
TypingFunctionGameState = require('../../../shared/TypingFunctionGameState.coffee')
validateExpression = require('../../../shared/validateExpression.coffee')

module.exports = React.createClass(
  displayName: 'StartedGame'

  getInitialState: ->
    expressions: ['sin(x)', 'sin(x)']

  componentDidMount: ->
    @sounds = 
      fire: play('/ping.wav').preload()
      obstacleHit: play('/explosion-1.mp3').preload()
      playerHit: play('/explosion-4.mp3').preload()
    @playedSounds = {}

  componentDidUpdate: ->
    sound = @props.data.gameState.sound
    if sound and !@playedSounds[sound.id]
      @playedSounds[sound.id] = true
      @sounds[sound.name].play()

  canFire: ->
    gameState = @props.data.gameState
    gameState instanceof TypingFunctionGameState and
    gameState.players.active().player.id == @props.data.playerId and
    validateExpression(@currentExpression().toLowerCase())

  handleSubmit: ->
    @props.pushMove(Moves.fire(@currentExpression().toLowerCase())) if @canFire()

  currentExpression: ->
    @state.expressions[@props.data.gameState.players.getNextDotIndex(@props.data.playerId)]

  handleExpressionChange: (newExpression) ->
    @state.expressions[@props.data.gameState.players.getNextDotIndex(@props.data.playerId)] = newExpression
    @forceUpdate()

  render: ->
    <Computer
      content={<Graph data={@props.data} />}
      timeRemaining={('0'+Math.round(@props.data.gameState.turnTime/100)).slice(-2)}
      value={@currentExpression()}
      onValueChange={@handleExpressionChange}
      buttonTitle='FIRE'
      buttonEnabled={@canFire()}
      buttonColor='black'
      onSubmit={@handleSubmit}
    />
)