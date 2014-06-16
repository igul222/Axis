React = require('react/addons')
client = require('../client.coffee')

Lobby = require('./lobby.coffee')

module.exports = React.createClass(
  componentDidMount: ->
    client.observe(this.props.params.id)

  componentWillUnmount: ->
    client.leave()

  render: ->
    if not this.props.data.game
      <div>Loading...</div> 
    else if not this.props.data.game.started
      <Lobby data={this.props.data} />
    else
      <div>Game on!</div>
)