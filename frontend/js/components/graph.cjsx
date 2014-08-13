Game  = require('../../../shared/game.coffee')
React = require('react/addons')
_     = require('lodash')


module.exports = React.createClass(
  AXIS_COLOR: 'rgb(0,0,0)'
  FUNCTION_COLOR: 'rgb(11,125,150)'
  FUNCTION_THICKNESS: 1 # px
  DOT_THICKNESS: 3 # px
  DOT_COLOR: 'rgb(150,0,0)'
  ACTIVE_DOT_COLOR: 'rgb(0,50,150)'
  DEAD_DOT_COLOR: 'rgb(150,150,150)'
  TEXT_FONT: '20px Helvetica Neue'
  TEXT_COLOR: 'rgb(15,15,15)'

  componentDidMount: ->
    context = @getDOMNode().getContext("2d")
    @lastAnimationTimestamp = 0
    requestAnimationFrame @tick
    @paint(context)

  tick: (animationTimestamp) ->
    dt = animationTimestamp - @lastAnimationTimestamp
    @lastAnimationTimestamp = animationTimestamp

    if @props.gameState.fn
      @extendFunction(dt)

    requestAnimationFrame @tick

  componentDidUpdate: ->
    context = @getDOMNode().getContext("2d")
    context.clearRect(
      0, 
      0, 
      @props.canvasWidth, 
      @_canvasHeight()
    )
    @paint(context)

  paint: (context) ->
    context.save()
    
    if @props.gameState.fn
      @drawEntireFunction(context)

    # Draw the axes
    context.beginPath()
    context.strokeStyle = @AXIS_COLOR
    context.moveTo(@_g2c(-Game::X_MAX, 0)...) # x axis
    context.lineTo(@_g2c( Game::X_MAX, 0)...)
    context.moveTo(@_g2c(0, -Game::Y_MAX)...) # y axis
    context.lineTo(@_g2c(0,  Game::Y_MAX)...)
    context.stroke()


    #draw all dots
    for team in @props.gameState.teams
      for player in team.players
        for dot in player.dots
          @drawDot(context, dot)
          @drawText(context, player.name, {x: dot.x, y: dot.y + 1})


    context.restore()

  # Convert game units to canvas pixels
  _toPx: (units) ->
    units * (0.5 * @props.canvasWidth / Game::X_MAX)

  # Returns the canvas height in pixels
  _canvasHeight: ->
    @_toPx(2*Game::Y_MAX)
 
  # Convert game coordinates to canvas coordinates
  _g2c: (x,y) ->
    flip = if @props.gameState.flipped then -1 else 1
    [
      @_toPx(Game::X_MAX + (flip * x)),
      @_toPx(Game::Y_MAX - y),
    ]

  drawDot: (context, dot) ->
    context.beginPath()
    context.arc(
      @_g2c(dot.x, dot.y)..., 
      @_toPx(Game::DOT_RADIUS) - @DOT_THICKNESS/2, 
      0, 
      2*Math.PI
    )
    context.lineWidth = @DOT_THICKNESS
    if dot.active
      context.strokeStyle = @ACTIVE_DOT_COLOR
    else if !dot.alive
      context.strokeStyle = @DEAD_DOT_COLOR
    else
      context.strokeStyle = @DOT_COLOR
    context.stroke()

  drawText: (context, text, origin) ->
    context.font = @TEXT_FONT
    context.fillStyle = @TEXT_COLOR
    context.fillText(text, @_g2c(origin.x, origin.y)...)

  drawEntireFunction: (context) ->
    @tMax = @props.gameState.time - @props.gameState.fn.startTime
    @drawFunctionSegment(context, 0, @tMax)

  extendFunction: (dt) ->
    context = @getDOMNode().getContext("2d")

    context.save()
    @drawFunctionSegment(context, @tMax, @tMax + dt)
    @tMax += dt

    context.restore()

  drawFunctionSegment: (context, t0, tMax) ->
    context.beginPath()
    context.lineWidth = @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR

    x0   = @props.gameState.fn.origin.x + (Game::FN_ANIMATION_SPEED*t0)
    xMax = @props.gameState.fn.origin.x + (Game::FN_ANIMATION_SPEED*tMax)

    context.moveTo(@_g2c(x0, @props.gameState.fn.evaluate(x0))...)

    dx = 1/@_toPx(1)

    for x in [x0 .. xMax] by dx
      y = @props.gameState.fn.evaluate(x)
      context.lineTo(@_g2c(x, y)...)

    context.stroke()

  render: ->
    <canvas
      style={background_color: "black"}
      width={@props.canvasWidth}
      height={@_canvasHeight()}
    />
)