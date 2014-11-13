page = require('page')

joinGame = (endpoint) ->
  r = new XMLHttpRequest()
  r.open('POST', (endpoint), true)
  r.onreadystatechange = ->
    return unless r.readyState == 4 and r.status == 200
    page('/games/'+ r.responseText)
  r.send()

module.exports = 
  public: -> joinGame('/joinPublicGame')
  private: -> joinGame('/createPrivateGame')