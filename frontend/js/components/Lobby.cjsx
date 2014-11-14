Moves = require('../../../shared/Moves.coffee')
Computer = require('./Computer.cjsx')

module.exports = React.createClass(
  displayName: 'Lobby'

  getInitialState: ->
    name: @props.data.gameState.players.get(@props.data.playerId).name
    validatesName: false

  gameCanStart: ->
    @props.data.gameState.players.teams[0].players.length > 0 and
    @props.data.gameState.players.teams[1].players.length > 0

  nameChanged: (newName)->
    @setState(name: newName)

  nameValid: ->
    @state.name.trim() != ''

  changeName: ->
    @props.pushMove(Moves.changeName(@state.name))

  handleSubmit: ->
    @props.pushMove(Moves.start())

  switchTeam: (id) ->
    @props.pushMove(Moves.switchTeam(id))

  render: ->
    if @props.data.gameState.players.get(@props.data.playerId).nameChanged
      teams = @props.data.gameState.players.teams.map (team, index) => team.players.map (player) =>
        direction = if index==0 then '->' else '<-'
        <li className ="player" key={player.id}>
          {player.name}
          <br />
          <button
            className="button switch-team-button"
            onClick={=>@switchTeam(player.id)}>
            {direction}
          </button>
        </li>
      content = 
        <div className="row lobby">
          <div className="col-sm-5 col-sm-offset-1">
            <h2 className="team-heading">Team 1</h2>
            <ul>{teams[0]}</ul>
          </div>
          <div className="col-sm-5">
            <h2 className="team-heading">Team 2</h2>
            <ul>{teams[1]}</ul>
          </div>
          <div className="col-sm-1" />
        </div>
      <div>
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

        <div className="input-group share">
          <span className="input-group-addon">share this url to play with your friends</span>
          <input type="text" className="form-control" value={window.location.href}>
          </input>
        </div>
      </div>

    else
      content =
        <div className="row finished-game-text">
          <div className="col-sm-12">
            Enter your nickname below
          </div>
        </div>
      <Computer
        content={content}
        timeRemaining='--'
        value={@state.name}
        onValueChange={@nameChanged}
        buttonTitle='JOIN'
        buttonEnabled={@nameValid()}
        buttonColor='black'
        onSubmit={@changeName}
      />
)