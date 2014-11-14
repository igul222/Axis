joinGame = require('../joinGame.coffee')
Computer = require('./Computer.cjsx')

module.exports = React.createClass(
  displayName: 'FinishedGame'
    
  handleSubmit: ->
    joinGame.public()

  render: ->
    content = <div className="centertext glowtext">
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
      value="Play again?"
      buttonTitle='PLAY'
      buttonEnabled={true}
      buttonColor='black'
      onSubmit={@handleSubmit}
    />
)