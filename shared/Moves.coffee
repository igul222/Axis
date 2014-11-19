module.exports = Moves =

  # Start the game on behalf of the player with the given id.
  # Only a player in the game can issue this move.
  start: () ->
    {type: 'start'}

  # Add a player (with given id and name) to the team with fewer players.
  # Only the server can issue this move.
  addPlayer: (playerId) ->
    return {type: 'addPlayer', playerId: playerId}

  # Remove the player with the given id from the game if he exists.
  # Only the server can issue this move.
  removePlayer: (playerId) ->
    return {type: 'removePlayer', playerId: playerId}

  # Sets the given player's typed expressions.
  setExpressions: (expressions) ->
    return {type: 'setExpressions', expressions: expressions}

  # Fire the given function from the currently active dot. Only the currently
  # active player can issue this move.
  fire: (expression) ->
    return {type: 'fire', expression: expression}

  # Switch the player with the given id to the other team
  switchTeam: (playerId) ->
    return {type: 'switchTeam', playerId: playerId}

  # Change the current agent's player's name to the given name
  changeName: (name)->
    return {type: 'changeName', name: name}

  # Send chat message from player
  # Any player can make this move at any time
  sendMessage: (message) ->
    return {type: 'sendMessage', message: message}