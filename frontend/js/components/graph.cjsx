Game  = require('../../../shared/game.coffee')
React = require('react/addons')
_     = require('lodash')

module.exports = React.createClass(
  AXIS_COLOR:            'rgb(245,255,245)'
  FUNCTION_COLOR:        'rgb(245,255,245)'
  DOT_COLOR:             'rgb(245,255,245)'
  ACTIVE_DOT_COLOR:      'rgb(245,255,245)'
  OBSTACLE_STROKE_COLOR: 'rgb(245,255,245)'
  OBSTACLE_FILL_COLOR:   'rgba(245,255,245,0.05)'

  DEAD_DOT_COLOR:        'rgba(245,255,245,0.5)'

  FUNCTION_THICKNESS: 1 # px

  DOT_THICKNESS: 1 # px
  ACTIVE_DOT_THICKNESS: 2 #px

  TEXT_SIZE: 14 # px
  TEXT_FONT: 'Monaco'
  TEXT_COLOR: 'rgb(245,255,245)'
  DEAD_TEXT_COLOR: 'rgba(245,255,245,0.5)'

  GLOW_COLOR: 'rgb(0,255,0)'
  GLOW_RADIUS: 5

  getInitialState: ->
    # The absolute dimensions set here don't matter, but canvas's css will
    # remember the aspect ratio.
    {
      scale: window.devicePixelRatio or 1
      canvasWidth: Game::X_MAX, 
      canvasHeight: Game::Y_MAX
    }

  componentDidMount: ->
    @lastAnimationTimestamp = 0
    @tickID = requestAnimationFrame @tick

    @updateCanvasSize()
    window.addEventListener('resize', @updateCanvasSize)

    @paint()

  tick: (animationTimestamp) ->
    dt = animationTimestamp - @lastAnimationTimestamp
    @lastAnimationTimestamp = animationTimestamp

    if @props.gameState.fn
      @extendFunction(dt)

    @tickID = requestAnimationFrame @tick

  updateCanvasSize: ->
    newWidth = @state.scale * @getCanvas().clientWidth
    newHeight = @state.scale * @getCanvas().clientHeight 

    if @state.canvasWidth != newWidth or @state.canvasHeight != newHeight
      @setState(canvasWidth: newWidth, canvasHeight: newHeight)

  componentWillUnmount: ->
    window.removeEventListener('resize', @updateCanvasSize)
    cancelAnimationFrame @tickID

  componentDidUpdate: ->
    @paint()

  getCanvas: ->
    @getDOMNode().querySelector('canvas')

  paint: (context) ->
    canvas = @getCanvas()
    context = canvas.getContext('2d')

    context.clearRect(
      0,
      0,
      @state.canvasWidth,
      @state.canvasHeight
    )
    context.save()

    context.shadowColor = @GLOW_COLOR;
    context.shadowBlur = @GLOW_RADIUS;

    # Draw the axes
    context.beginPath()
    context.strokeStyle = @AXIS_COLOR
    context.moveTo(@_g2c(-Game::X_MAX, 0)...) # x axis
    context.lineTo(@_g2c( Game::X_MAX, 0)...)
    context.moveTo(@_g2c(0, -Game::Y_MAX)...) # y axis
    context.lineTo(@_g2c(0,  Game::Y_MAX)...)
    context.stroke()

    #draw all obstacles
    for obstacle in @props.gameState.obstacles
      @drawObstacle(context, obstacle)

    for antiobstacle in @props.gameState.antiobstacles
      @drawAntiObstacle(context, antiobstacle)

    #draw all dots
    for team in @props.gameState.teams
      for player in team.players
        for dot in player.dots
          active = dot.active and player.active and team.active
          @drawDot(context, dot, active)
          @drawText(
            context, 
            player.name,
            if dot.alive then @TEXT_COLOR else @DEAD_TEXT_COLOR,
            {x: dot.x, y: dot.y + 1}
          )

    if @props.gameState.fn
      @drawEntireFunction(context)

    context.restore()

  # Returns the canvas width in pixels
  _canvasWidth: ->
    @state.canvasWidth

  # Returns the canvas height in pixels
  _canvasHeight: ->
    @state.canvasHeight

  # Convert game units to canvas pixels
  _toPx: (units, vertical = false) ->
    if vertical
      units * (0.5 * @state.canvasHeight / Game::Y_MAX)
    else
      units * (0.5 * @state.canvasWidth / Game::X_MAX)
 
  # Convert game coordinates to canvas coordinates
  _g2c: (x,y) ->
    flip = if @props.gameState.flipped then -1 else 1
    [
      @_toPx(Game::X_MAX + (flip * x)),
      @_toPx(Game::Y_MAX - y, true),
    ]

  drawDot: (context, dot, dotActive) ->
    if dotActive and @props.gameState.time % 1000 < 500
      scaledThickness = @state.scale * @ACTIVE_DOT_THICKNESS
    else
      scaledThickness = @state.scale * @DOT_THICKNESS

    context.beginPath()
    context.arc(
      @_g2c(dot.x, dot.y)..., 
      @_toPx(Game::DOT_RADIUS) - (scaledThickness/2), 
      0, 
      2*Math.PI
    )
    context.lineWidth = scaledThickness
    if dotActive
      context.strokeStyle = @ACTIVE_DOT_COLOR
    else if !dot.alive
      context.strokeStyle = @DEAD_DOT_COLOR
    else
      context.strokeStyle = @DOT_COLOR
    context.stroke()

  drawAntiObstacle: (context, ao)->
    context.save()
    context.beginPath()
    context.arc(
      @_g2c(ao.x, ao.y)..., 
      @_toPx(Game::ANTIOBSTACLE_RADIUS), 
      0,
      2*Math.PI
    )

    context.clip()
    context.clearRect(
      0,
      0,
      @state.canvasWidth,
      @state.canvasHeight
    )

    context.restore()

  drawObstacle: (context, obstacle) ->
    context.beginPath()

    context.fillStyle = @OBSTACLE_FILL_COLOR
    context.strokeStyle = @OBSTACLE_STROKE_COLOR

    context.arc(
      @_g2c(obstacle.x, obstacle.y)...,
      @_toPx(obstacle.radius),
      0,
      2*Math.PI
    )

    context.fill()
    context.stroke()

  drawText: (context, text, color, origin) ->
    context.font = (@TEXT_SIZE*@state.scale)+'px '+@TEXT_FONT
    context.textAlign = 'center'
    context.fillStyle = color
    context.fillText(text.toUpperCase(), @_g2c(origin.x, origin.y)...)

  drawEntireFunction: (context) ->
    @tMax = @props.gameState.time - @props.gameState.fn.startTime
    @drawFunctionSegment(context, 0, @tMax)

  extendFunction: (dt) ->
    context = @getCanvas().getContext('2d')

    context.save()
    @drawFunctionSegment(context, @tMax, @tMax + dt)
    @tMax += dt

    context.restore()

  drawFunctionSegment: (context, t0, tMax) ->
    context.beginPath()
    context.lineWidth = @state.scale * @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR
    flip = if @props.gameState.fn.origin.x > 0 then -1 else 1

    x0   = @props.gameState.fn.origin.x + (flip*Game::FN_ANIMATION_SPEED*t0)
    xMax = @props.gameState.fn.origin.x + (flip*Game::FN_ANIMATION_SPEED*tMax)

    context.moveTo(@_g2c(x0, @props.gameState.fn.evaluate(x0))...)

    dx = 1/@_toPx(1)

    for x in [x0 .. xMax] by flip*dx
      y = @props.gameState.fn.evaluate(x)
      context.lineTo(@_g2c(x, y)...)
    context.lineTo(@_g2c(xMax, @props.gameState.fn.evaluate(xMax))...)

    context.stroke()

  render: ->
    <div id='canvas-wrapper'>
      <canvas
        width={@state.canvasWidth}
        height={@state.canvasHeight}
      />
    </div>
)