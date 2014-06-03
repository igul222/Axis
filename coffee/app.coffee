React = require('react')

App = React.createClass(
  render: ->
    return <h1>Hello, world!</h1>
)

app = React.renderComponent(<App />, document.body)