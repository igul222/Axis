page  = require('page')

module.exports = React.createClass(
  mixins: [React.addons.LinkedStateMixin]

  joinPublicGame: (e) ->
    e.preventDefault()
    r = new XMLHttpRequest()
    r.open('POST', '/joinPublicGame', true)
    r.onreadystatechange = ->
      return unless r.readyState == 4 and r.status == 200
      page('/games/'+ r.responseText)
    r.send()

  render: ->
    <button
      className="btn btn-primary btn-lg"
      onClick={@joinPublicGame}
      >
      Join a game
    </button>
)