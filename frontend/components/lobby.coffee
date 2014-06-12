React = require('react/addons')
_     = require('underscore')

module.exports = React.createClass(
  teams: ->
    teams = _.groupBy(this.props.data.game.players, 'team')
    [teams[0] || [], teams[1] || []] # convert object to array

  gameCanStart: ->
    @teams()[0].length > 1 && @teams()[1].length > 1

  startGame: ->
    # TODO implement

  render: ->
    teams = @teams().map (team) -> team.map (player) ->
      <li key={player.name}>{player.name}</li>

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