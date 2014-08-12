jsdom = require('jsdom').jsdom

module.exports =
  initDOM: ->
    _.assign(global, require('request-animation-frame'))

    global.window = jsdom().createWindow('<html><body></body></html>')
    global.document = window.document
    global.navigator = window.navigator

  cleanDOM: ->
    delete global.window
    delete global.document
    delete global.navigator