#!/usr/bin/env coffee
# Starts the web server

# Express
http    = require('http')
express = require('express')
app     = express()

app.set 'port', process.env.PORT || 3000
app.use express.static('public')

# logger
if app.get('env')=='development'
  app.use require('morgan')('dev')
else 
  app.use require('morgan')

app.get '/*', (req, res) ->
  res.sendfile('public/index.html')

http.createServer(app).listen app.get('port'), (err) ->
  if err
    console.log 'Fatal error: '+err
  else
    console.log 'Express server listening on port ' + app.get('port')