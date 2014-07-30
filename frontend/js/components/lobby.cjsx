React = require('react/addons')
_     = require('underscore')
client  = require('../client.coffee')

module.exports = React.createClass(
  gameCanStart: ->
    @props.data.gameState.teams[0].players.length > 0 &&
    @props.data.gameState.teams[1].players.length > 0

  startGame: ->
    client.start()

  render: ->
    teams = @props.data.gameState.teams.map (team) -> team.players.map (player) ->
      <li key={player.id}>{player.name}</li>

    <div className="row">
      <div className="col-sm-push-3 col-sm-6">
        <div className="row">

          <div className="col-sm-6">
            <h2>Team 1</h2>
            <ul>{teams[0]}</ul>
          </div>
          <div className="col-sm-6">
            <h2>Team 2</h2>
            <ul>{teams[1]}</ul>
          </div>

        </div>

        <div className="row">
          <div className="col-sm-12">
            <button
              disabled={!@gameCanStart()}
              className="btn btn-primary btn-lg"
              onClick={@startGame}
              >
              Start game
            </button>
          </div>
        </div>

      </div>
    </div>
)