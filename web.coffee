#!/usr/bin/env coffee
# Starts the web server

# Express
express = require('express')
app     = express()
http    = require('http').Server(app)

# Socket.io
io      = require('socket.io')(http);

Game = require('./backend/Game')
Moves = require('./shared/Moves')

app.set 'port', process.env.PORT || 3000
app.use express.static('public')

if app.get('env')=='development'
  app.use require('morgan')('dev') # logger
  app.use require('connect-livereload')()
else 
  app.use require('morgan')('default')

# Game subscription socket handlers
io.on 'connection', (socket) ->
  socket.on 'subscribe', (gameId) ->

    game = Game.getById(gameId)

    game.pushMove(Moves.addPlayer(socket.id), null)
    game.subscribe socket.id, (data) ->
      socket.emit 'data', data

    socket.on 'pushMove', (move) ->
      game.pushMove(move, socket.id)
      Game.resetOpenGame() if move.type == 'start'

    socket.on 'disconnect', ->
      game.pushMove(Moves.removePlayer(socket.id), null)
      game.unsubscribe(socket.id)

players = 0
app.post '/joinPublicGame', (req, res) ->
  Game.resetOpenGame() if players++ % 4 == 0
  res.send(Game.openGameId)

# Serve index.jade for all other routes
app.set 'views', __dirname + '/backend'
app.get '/*', (req, res) ->
  res.render('index.jade')

# Start the server
http.listen app.get('port'), '0.0.0.0', (err) ->
  if err
    console.log 'Fatal error: '+err
  else
    console.log 'Express server listening on 0.0.0.0:' + app.get('port')