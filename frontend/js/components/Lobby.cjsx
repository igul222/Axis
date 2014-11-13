Moves = require('../../../shared/Moves.coffee')
Computer = require('./Computer.cjsx')

module.exports = React.createClass(
  displayName: 'Lobby'

  gameCanStart: ->
    @props.data.gameState.players.teams[0].players.length > 0 and
    @props.data.gameState.players.teams[1].players.length > 0

  handleSubmit: ->
    @props.pushMove(Moves.start())

  render: ->
    teams = @props.data.gameState.players.teams.map (team) -> team.players.map (player) ->
      <li key={player.id}>{player.name}</li>

    content = <div className="row lobby">
      <div className="col-sm-6">
        <h2>Team 1</h2>
        <ul>{teams[0]}</ul>
      </div>
      <div className="col-sm-6">
        <h2>Team 2</h2>
        <ul>{teams[1]}</ul>
      </div>
    </div>

    <Computer
      content={content}
      timeRemaining='--'
      value={
        if @gameCanStart() 
          "Press START to begin!"
        else 
          "Waiting for more players..."
      }
      buttonTitle='START'
      buttonEnabled={@gameCanStart()}
      buttonColor='black'
      onSubmit={@handleSubmit}
    />
)