#!/usr/bin/env coffee
# Starts the web server

# Express
express = require('express')
app     = express()
http    = require('http').Server(app)
compress = require('compression')(
  threshold: 95
);

# Socket.io
io      = require('socket.io')(http);

Game = require('./backend/Game')
Moves = require('./shared/Moves')

app.set 'port', process.env.PORT || 3000
app.use(compress);
app.use express.static('public')

if app.get('env')=='development'
  app.use require('morgan')('dev') # logger
  app.use require('connect-livereload')()
else 
  app.use require('morgan')('default')

openGamePlayers = 0

app.post '/joinPublicGame', (req, res) ->
  Game.resetOpenGame() if openGamePlayers++ % 4 == 0
  res.send(Game.openGameId)

app.post '/createPrivateGame', (req, res) ->
  gameId = Game.createPrivateGame()
  res.send(gameId)

# Game subscription socket handlers
io.on 'connection', (socket) ->
  socket.on 'subscribe', (gameId) ->
    game = Game.getById(gameId)
    if game

      game.pushMove(Moves.addPlayer(socket.id), null)

      game.subscribe socket.id, (data) ->
        socket.emit 'data', data

      socket.on 'pushMove', (move) ->
        game.pushMove(move, socket.id)
        if move.type == 'start'
          Game.resetOpenGame()
          openGamePlayers = 0

      socket.on 'disconnect', ->
        game.unsubscribe(socket.id)
        game.pushMove(Moves.removePlayer(socket.id), null)

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