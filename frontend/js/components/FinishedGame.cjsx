joinPublicGame = require('../joinPublicGame.coffee')
Computer = require('./Computer.cjsx')

module.exports = React.createClass(
  displayName: 'FinishedGame'
    
  handleSubmit: ->
    joinPublicGame()

  render: ->
    content = <div id="finished-screen-text">
      {
        if @props.data.gameState.players.isWinner(@props.data.playerId)
          "YOU WIN!"
        else
          "YOU LOSE."
      }
    </div>

    <Computer
      content={content}
      timeRemaining='--'
      value="Press PLAY to play again..."
      buttonTitle='PLAY'
      buttonEnabled={true}
      onSubmit={@handleSubmit}
    />
)