Moves = require('../../../shared/Moves.coffee')
Computer = require('./Computer.cjsx')

module.exports = React.createClass(
  displayName: 'Lobby'

  getInitialState: ->
    name: @props.data.gameState.players.get(@props.data.playerId).name
    validatesName: false

  nameChanged: (newName)->
    @setState(name: newName)

  nameValid: ->
    @state.name.trim() != ''

  submitName: ->
    @props.pushMove(Moves.changeName(@state.name))

  handleURLClick: (e) ->
    e.target.setSelectionRange(0, e.target.value.length)

  switchPlayerTeam: (playerId) ->
    console.log 'switchPlayerTeam ', playerId
    @props.pushMove(Moves.switchTeam(playerId))

  gameCanStart: ->
    @props.data.gameState.players.teams[0].players.length > 0 and
    @props.data.gameState.players.teams[1].players.length > 0

  startGame: ->
    @props.pushMove(Moves.start())

  render: ->
    if @props.data.gameState.players.get(@props.data.playerId).nameChanged
      content = 
        <div className="lobby-wrapper">
          <div className="url-wrapper">
            <span>share this url to play with your friends: </span>
            <input value={window.location.href} onClick={@handleURLClick} readOnly={true} />
          </div>

          <div className="teams">
            {
              for team, index in @props.data.gameState.players.teams
                <div className="team" key={index}>
                  <div className="team-heading">Team {index + 1}</div>
                  {
                    for player in team.players
                      do (player) =>
                        <div className="player" key={player.id}>
                          <span className="name">┕  {player.name}</span>
                          <button onClick={ => @switchPlayerTeam(player.id) }>
                            [switch]
                          </button>
                        </div>
                  }
                </div>
            }
          </div>
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
          onSubmit={@startGame}
        />
      </div>

    else
      <Computer
        content={<div className="glowtext centertext">Type your nickname below.</div>}
        timeRemaining='--'
        value={@state.name}
        onValueChange={@nameChanged}
        buttonTitle='JOIN'
        buttonEnabled={@nameValid()}
        buttonColor='black'
        onSubmit={@submitName}
      />
)