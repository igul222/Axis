React = require('react/addons')
page  = require('page')

game = require('./game_client.coffee')
Welcome = require('./welcome.coffee')

App = React.createClass(
  render: ->
    # Initial render, before router and game client initialize.
    return <div/> unless this.props.ctx and this.props.data

    # Choose different content based on the current route context.
    switch this.props.ctx.pathname
      when '/' then content = <Welcome data={this.props.data} />
      else content = <pre>props: {JSON.stringify(this.props)}</pre>

    <div>
      <div className="navbar navbar-default navbar-static-top">
        <div className="container">
          <a className="navbar-brand" href="/">Axis</a>
        </div>
      </div>
      <div className="container">{content}</div>
    </div>
)

app = React.renderComponent(<App />, document.body)

# Connect game client
game.subscribe (data) ->
  app.setProps({data})

# Define routes
setCtx = (ctx) -> app.setProps({ctx})
page '/*', setCtx
page '/games/:gameId', setCtx
page()