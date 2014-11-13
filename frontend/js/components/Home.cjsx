Button = require('./Button.cjsx')
Computer = require('./Computer.cjsx')
Graph = require('./Graph.cjsx')

GameState = require('../../../shared/GameState.coffee')
Moves = require('../../../shared/Moves.coffee')
Players = require('../../../shared/Players.coffee')

joinGame = require('../joinGame.coffee')

Step = React.createClass(
  displayName: 'Step'
  render: ->
    <div className="step">
      <div className="instructions-container">
        {@props.children}
      </div>
      <Computer
        content={<Graph data={@props.data} notAnimated={true} />}
        timeRemaining={@props.timeRemaining or '  '}
        value={@props.expression or ''}
        buttonTitle='FIRE'
        buttonEnabled={false}
      />
    </div>
)

Instr = React.createClass(
  displayName: 'Instr'
  render: ->
    <p className="instructions">{@props.children}</p>
)

module.exports = React.createClass(
  displayName: 'Home'

  handleJoinGame: ->
    joinGame.public()

  handleCreateGame: ->
    joinGame.private()

  handleWatchVideo: ->
    window.location = "https://www.youtube.com/watch?v=yO0aEv_0Aeo"

  getDataForStep: (step)->
    state = GameState.new(0.314159)
      .handleMove(Moves.addPlayer(1))
      .handleMove(Moves.addPlayer(2))

    startMove = Moves.start()
    startMove.agentId = 1
    state = state.handleMove(startMove)

    fnMove = Moves.fire('-0.36x')
    fnMove.agentId = 1
    state = state.handleMove(fnMove)
    
    state = state.tick() for i in [1..295]

    if step == 0
      state.players = new Players()
    if step <= 1
      state.obstacles._obstacles = []
      state.obstacles._generateObstaclePaths()
    if step <= 2
      state.fn = null

    {gameState: state, playerId: 1}

  render: ->
    <div className="container home-container">
      <div className="row">
        <div className="home-left">
          <img className='logo' src="/logo.png" />
          <Button
            title='Join Public Game'
            onClick={@handleJoinGame}
            color='red'
          />
          <Button
            title='Create Private Game'
            onClick={@handleCreateGame}
            color='green'
          />
          <Button
            title='Watch Video'
            onClick={@handleWatchVideo}
            color='blue'
          />
          <p>Made by <a href="http://twitter.com/zan2434">Zain</a> & <a href="http://twitter.com/__ishaan">Ishaan</a>, based on <a href="http://graphwar.com">Graphwar</a>.</p>
        </div>

        <div className="home-right">

          <h1>How to Play</h1>

          <Step data={@getDataForStep(0)}>
            <Instr>In this game you fire missiles at your enemies, like any other game, but you <strong>aim</strong> with mathematical functions.</Instr>
            <Instr>This is your playing field.</Instr>
          </Step>

          <Step data={@getDataForStep(1)} timeRemaining='42'>
            <Instr>You and your whole team are on the left, while your enemies are on the right.</Instr>
            <Instr>You have multiple units representing you on your team, but the one that is currently active will light up and blink</Instr>
            <Instr>The timer in the bottom left tells you how much time you have left to fire, and you input your function in the box to its right.</Instr>
          </Step>

          <Step data={@getDataForStep(2)} timeRemaining='42'>
            <Instr>
              There are also some obstacles on the map here. 
              You must carefully avoid hitting them with your missile. 
              Your missile will explode prematurely if it hits an obstacle or exits the map.
            </Instr>
            <Instr>
              They will take some damage though, so if you're really stuck
              (and your opponent isn't going to craft something sneakier in the meantime)
              you can eventually tunnel your way through by shooting at it.
            </Instr>
          </Step>

          <Step data={@getDataForStep(3)} timeRemaining='42' expression='-0.36x'>
            <Instr>
              To successfully fire at your enemy, devise a function that will avoid the obstacles
              and intersect with your target. This can be a line, a sine wave, an exponential function.
              Anything dependent on x that could be set equal to y.
            </Instr>
            <Instr>
              Keep in mind that your active player dot is the origin to the function.
              So x = 0 for the function wherever you are, and x increases to the right.
            </Instr>
            <Instr>
              For a line directly aimed at player 2, recall the slope form of a line: <br />
              <code> y = m * x </code> &nbsp; where <code>m = slope = dy/dx</code> <br />
            </Instr>
            <Instr>
              dy and dx are the distance in y and x, respectively. <br />
              According to the axis labels, Player 2 is about 9 units below us and 25 units to the right. <br />
              Our slope, m, is therefore -9/25 = -0.36
            </Instr>
          </Step>

        </div>
      </div>
    </div>
)