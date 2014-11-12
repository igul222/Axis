joinPublicGame = require('../joinPublicGame.coffee')

module.exports = React.createClass(
  displayName: 'Home'
  mixins: [React.addons.LinkedStateMixin]

  joinPublicGame: (e) ->
    e.preventDefault()
    joinPublicGame()

  render: ->
    <button
      className="btn btn-primary btn-lg"
      onClick={@joinPublicGame}
      >
      Join a game
    </button>
)