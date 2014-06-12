React = require('react/addons')
game  = require('../game_client.coffee')

Lobby = require('./lobby.coffee')

module.exports = React.createClass(
  componentDidMount: ->
    game.observe(this.props.params.id)

  componentWillUnmount: ->
    game.leave()

  render: ->
    if not this.props.data.game
      <div>Loading...</div> 
    else if not this.props.data.game.started
      <Lobby data={this.props.data} />
    else
      <div>Game on!</div>
)