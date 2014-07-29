React = require('react/addons')
client = require('../client.coffee')


Lobby = require('./lobby.cjsx')
Gameplay = require("./gameplay.cjsx")


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
      <Gameplay data={this.props.data} />
)