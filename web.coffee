#!/usr/bin/env coffee
# Starts the web server

# Express
express = require('express')
app     = express()
http    = require('http').Server(app)

# Socket.io
io      = require('socket.io')(http);

app.set 'port', process.env.PORT || 3000
app.use express.static('public')

if app.get('env')=='development'
  app.use require('morgan')('dev') # logger
  app.use require('connect-livereload')()
else 
  app.use require('morgan')

# Serve index.html for all routes
app.get '/*', (req, res) ->
  res.render('app.jade')

# Load the socket.io handlers
require('./server.coffee')(io)

# Start the server
http.listen app.get('port'), (err) ->
  if err
    console.log 'Fatal error: '+err
  else
    console.log 'Express server listening on port ' + app.get('port')