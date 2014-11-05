window.React = require('react/addons') # Global require for dev tools

page  = require('page')
WelcomePage = require('./components/welcome_page.cjsx')
GamePage    = require('./components/game_page.cjsx')
Chat = require('./components/chat.cjsx')

window.pp = (x) -> console.log(JSON.stringify(x,null,4))

App = React.createClass(
  displayName: 'App'

  render: ->
    # Initial render, before router initializes.
    return <div/> unless this.props.route

    # Choose different content based on the current route context.
    switch this.props.route
      when 'welcome'
        content = <WelcomePage />
      when 'game'
        content = <GamePage params={this.props.params} />
        # chat = null
        # # if @props.data.gameState?
        # #   chat = <div className="sidebar col sm-6 pull-right"><Chat gameState={this.props.data.gameState} /></div>
      else
        content = <pre>props: {JSON.stringify(this.props, null, 4)}</pre>

    <div>
      <div className="navbar navbar-inverse navbar-static-top">
        <div className="container">
          <a className="navbar-brand" href="/">Axis</a>
        </div>
      </div>
      <div className="container">{content}</div>
    </div>
)

app = React.renderComponent(<App />, document.body)

goto = (route) -> ((ctx) -> app.setProps(route: route, params: ctx.params))
page '/games/:id', goto('game')
page '/', goto('welcome')
page()