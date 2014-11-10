window.React = require('react/addons') # Global require for dev tools

page  = require('page')
WelcomePage = require('./components/welcome_page.cjsx')
GamePage    = require('./components/game_page.cjsx')

window.pp = (x) -> console.log(JSON.stringify(x,null,4))

App = React.createClass(
  displayName: 'App'

  render: ->
    # Choose different content based on the current route context.
    switch this.props.route
      when 'welcome'
        return <WelcomePage />
      when 'game'
        return <GamePage params={this.props.params} />
      else
        return <div />
)

app = React.renderComponent(<App />, document.body)

goto = (route) -> ((ctx) -> app.setProps(route: route, params: ctx.params))
page '/games/:id', goto('game')
page '/', goto('welcome')
page()