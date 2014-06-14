React = require('react/addons')
game  = require('../game_client.coffee')

module.exports = React.createClass(
  getInitialState: ->
    validatesName: false

  nameChanged: (e) ->
    game.setPlayerName(e.target.value)

  nameBlurred: (e) ->
    this.setState(validatesName: true)

  nameValid: ->
    this.props.data.playerName.trim() != ''

  joinPublicGame: ->
    game.joinPublicGame()

  render: ->
    cx = React.addons.classSet

    <div className="row">
      <div className="col-sm-push-3 col-sm-6">

        <div className={cx(
          'form-group': true,
          'has-error': this.state.validatesName && !this.nameValid(),
          'has-success': this.state.validatesName && this.nameValid()
          )}>

          <label className="control-label" htmlFor="name">Choose a name</label>
          <input type="text"
            className="form-control"
              id="name"
              value={this.props.data.playerName}
              onBlur={this.nameBlurred}
              onChange={this.nameChanged} />

        </div>

        <button
          disabled={!this.nameValid()}
          className="btn btn-primary btn-lg"
          onClick={this.joinPublicGame}
          >
          Join a game
        </button>

      </div>
    </div>
)