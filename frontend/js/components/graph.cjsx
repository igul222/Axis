_     = require('lodash')

StartedGameState = require('../../../shared/StartedGameState.coffee')
FiringGameState = require('../../../shared/FiringGameState.coffee')
Players = require('../../../shared/Players.coffee')

module.exports = React.createClass(
  AXIS_COLOR:            'rgb(245,255,245)'
  FUNCTION_COLOR:        'rgb(245,255,245)'
  DOT_COLOR:             'rgb(245,255,245)'
  ACTIVE_DOT_COLOR:      'rgb(245,255,245)'
  OBSTACLE_STROKE_COLOR: 'rgb(245,255,245)'
  OBSTACLE_FILL_COLOR:   'rgba(245,255,245,0.1)'

  DEAD_DOT_COLOR:        'rgba(245,255,245,0.5)'

  FUNCTION_THICKNESS: 1 # px

  DOT_THICKNESS: 1 # px
  ACTIVE_DOT_THICKNESS: 4 #px

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
      canvasWidth: StartedGameState.XMax
      canvasHeight: StartedGameState.YMax
    }

  render: ->
    <canvas
      width={@state.canvasWidth}
      height={@state.canvasHeight}
    />

  componentDidMount: ->
    unless @props.notAnimated
      @lastAnimationTimestamp = 0
      @tickID = requestAnimationFrame @tick

    @updateCanvasSize()
    window.addEventListener('resize', @updateCanvasSize)

    @flip = if @props.data.gameState.players.isFlipped(@props.data.playerId) then -1 else 1
    @paint()

  componentWillUnmount: ->
    window.removeEventListener('resize', @updateCanvasSize)
    unless @props.notAnimated
      cancelAnimationFrame @tickID

  componentDidUpdate: ->
    @flip = if @props.data.gameState.players.isFlipped(@props.data.playerId) then -1 else 1
    @paint()

  tick: (animationTimestamp) ->
    dt = (animationTimestamp - @lastAnimationTimestamp) / 10
    @lastAnimationTimestamp = animationTimestamp

    if @props.data.gameState.fn
      @extendFunction(dt)

    @tickID = requestAnimationFrame @tick

  updateCanvasSize: ->
    newWidth = @state.scale * @getCanvas().clientWidth
    newHeight = @state.scale * @getCanvas().clientHeight 

    if @state.canvasWidth != newWidth or @state.canvasHeight != newHeight
      @setState(canvasWidth: newWidth, canvasHeight: newHeight)

  getCanvas: ->
    @getDOMNode()

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

    context.shadowColor = @GLOW_COLOR
    context.shadowBlur = @GLOW_RADIUS

    # Draw the axes
    context.beginPath()
    context.strokeStyle = @AXIS_COLOR
    context.moveTo(@_g2c(-StartedGameState.XMax, 0)...) # x axis
    context.lineTo(@_g2c( StartedGameState.XMax, 0)...)
    context.moveTo(@_g2c(0, -StartedGameState.YMax)...) # y axis
    context.lineTo(@_g2c(0,  StartedGameState.YMax)...)
    context.stroke()

    # label the axes
    @drawText(
        context,
        '-25',
        @TEXT_COLOR,
        {x: -(@flip*(StartedGameState.XMax-1)), y: -1}
      )
    @drawText(
        context,
        '-15',
        @TEXT_COLOR,
        {x: 1, y: -14.5}
      )
    @drawText(
        context,
        '15',
        @TEXT_COLOR,
        {x: 1, y: 14}
      )
    @drawText(
        context,
        '25',
        @TEXT_COLOR,
        {x: (@flip*(StartedGameState.XMax-1)), y: -1}
      )

    #draw all obstacles
    @drawObstacles(context, @props.data.gameState)

    #draw all dots
    for team in @props.data.gameState.players.teams
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

    if @props.data.gameState.fn
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
      units * (0.5 * @state.canvasHeight / StartedGameState.YMax)
    else
      units * (0.5 * @state.canvasWidth / StartedGameState.XMax)
  
  # Convert game coordinates to canvas coordinates
  _g2c: (x,y) ->
    [
      @_toPx(StartedGameState.XMax + (@flip * x)),
      @_toPx(StartedGameState.YMax - y, true),
    ]

  drawDot: (context, dot, dotActive) ->
    if dotActive and @props.data.gameState.timer % 200 < 100
      scaledThickness = @state.scale * @ACTIVE_DOT_THICKNESS
    else
      scaledThickness = @state.scale * @DOT_THICKNESS

    context.beginPath()
    context.arc(
      @_g2c(dot.x, dot.y)..., 
      @_toPx(Players.DotRadius) - (scaledThickness/2), 
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

  drawObstacles: (context, state) ->
    context.fillStyle = @OBSTACLE_FILL_COLOR
    context.strokeStyle = @OBSTACLE_STROKE_COLOR

    for path in state.obstacles.paths

      context.beginPath()

      lastPoint = path[path.length - 1]
      context.moveTo(@_g2c(lastPoint.x, lastPoint.y)...)
      
      for point in path
        context.lineTo(@_g2c(point.x, point.y)...)
      context.closePath()

      context.fill()
      context.stroke()

  drawText: (context, text, color, origin) ->
    context.font = (@TEXT_SIZE*@state.scale)+'px '+@TEXT_FONT
    context.textAlign = 'center'
    context.fillStyle = color
    context.fillText(text.toUpperCase(), @_g2c(origin.x, origin.y)...)

  drawEntireFunction: (context) ->
    @fnX = @props.data.gameState.fn.x
    @drawFunctionSegment(context, @props.data.gameState.fn.origin.x, @fnX)

  extendFunction: (dt) ->
    context = @getCanvas().getContext('2d')
    context.save()

    context.shadowColor = @GLOW_COLOR
    context.shadowBlur = @GLOW_RADIUS

    dx = dt * @props.data.gameState.fn.flip * FiringGameState.FunctionAnimationSpeed
    @drawFunctionSegment(context, @fnX, @fnX + dx)
    @fnX += dx

    context.restore()

  drawFunctionSegment: (context, x0, xMax) ->
    context.beginPath()
    context.lineWidth = @state.scale * @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR

    context.moveTo(@_g2c(x0, @props.data.gameState.fn.evaluate(x0))...)

    dx = 1/@_toPx(1)

    for x in [x0 .. xMax] by @props.data.gameState.fn.flip * dx
      y = @props.data.gameState.fn.evaluate(x)
      context.lineTo(@_g2c(x, y)...)
    context.lineTo(@_g2c(xMax, @props.data.gameState.fn.evaluate(xMax))...)

    context.stroke()
)