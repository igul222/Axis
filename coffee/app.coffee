React = require('react/addons')
page  = require('page')

Welcome = require('./welcome.coffee')

App = React.createClass(
  render: ->
    # initial render, before the router initializes 
    return <div/> unless this.props.ctx

    switch this.props.ctx.pathname
      when '/' then content = <Welcome />
      else content = <div />
    
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

setCtx = (ctx) -> app.setProps({ctx})
page '/*', setCtx
page()