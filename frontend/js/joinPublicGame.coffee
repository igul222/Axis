page = require('page')

module.exports = ->
  r = new XMLHttpRequest()
  r.open('POST', '/joinPublicGame', true)
  console.log 'sending request'
  r.onreadystatechange = ->
    console.log 'got response'
    return unless r.readyState == 4 and r.status == 200
    console.log 'redirecting to '+'/games/'+r.responseText
    page('/games/'+ r.responseText)
  r.send()