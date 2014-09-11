React = require('react/addons')
page  = require('page')
WelcomePage = require('./components/welcome_page.cjsx')
GamePage    = require('./components/game_page.cjsx')
Chat = require('./components/chat.cjsx')

window.gameClient = require('./client.coffee')
window.pp = (x) -> console.log(JSON.stringify(x,null,4))

App = React.createClass(
  render: ->
    # Initial render, before router and game client initialize.
    return <div/> unless this.props.route and this.props.data

    # Choose different content based on the current route context.
    switch this.props.route
      when 'welcome'
        content = <WelcomePage data={this.props.data} />
      when 'game'
        content = <GamePage params={this.props.params} data={this.props.data} />
        chat = null
        if this.props.data.gameState !=null and this.props.data.gameState.started
          chat = <div className="sidebar col sm-6 pull-right"><Chat gameState={this.props.data.gameState} /></div>
      else
        content = <pre>props: {JSON.stringify(this.props, null, 4)}</pre>

    <div>
      <div className="navbar navbar-inverse navbar-static-top">
        <div className="container">
          <a className="navbar-brand" href="/">Axis</a>
        </div>
      </div>
      {chat}
      <div className="container">{content}</div>
    </div>
)

app = React.renderComponent(<App />, document.body)

# Connect client
window.gameClient.subscribe (data) ->
  app.setProps({data})

# Routing
goto = (route) -> ((ctx) -> app.setProps(route: route, params: ctx.params))
page '/games/:id', goto('game')
page '/', goto('welcome')
page()