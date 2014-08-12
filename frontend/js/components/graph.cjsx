Game  = require('../../../shared/game.coffee')
React = require('react/addons')
_     = require('lodash')


module.exports = React.createClass(
  AXIS_COLOR: 'rgb(0,0,0)'
  FUNCTION_COLOR: 'rgb(11,125,150)'
  FUNCTION_THICKNESS: 1 # 3px
  DOT_COLOR: 'rgb(150,0,0)'
  ACTIVE_DOT_COLOR: 'rgb(0,50,150)'
  DOT_RADIUS: 10 # 10 px
  DOT_THICKNESS: 3 # 3 px
  TEXT_FONT: '20px Helvetica Neue'
  TEXT_COLOR: 'rgb(15,15,15)'

  getInitialState: ->
    t: 0.0

  componentDidMount: ->
    context = @getDOMNode().getContext("2d")
    requestAnimationFrame @tick
    @paint(context)

  tick: ->
    @setState t: @state.t + 1
    requestAnimationFrame @tick

  componentDidUpdate: ->
    context = @getDOMNode().getContext("2d")
    context.clearRect(0, 0, @props.width, @props.height)
    @paint(context)

  paint: (context) ->
    console.log 'painting'
    context.save()

    # Draw the axes
    x0 = 0.5 * @props.width
    y0 = 0.5 * @props.height
    context.beginPath()
    context.strokeStyle = @AXIS_COLOR
    context.moveTo(0, y0) # x axis
    context.lineTo(@props.width, y0)
    context.moveTo(x0, 0) # y axis
    context.lineTo(x0, @props.height)
    context.stroke()

    #draw all dots
    for team in @props.gameState.teams
      for player in team.players
        for dot in player.dots
          @drawDot(context, dot)
          @drawText(context, player.name, {x: dot.x + 0.75, y: dot.y + 0.75})

    if @props.gameState.fn
      @drawFunction(context)

    context.restore()
 
  # Convert graph coordinates to canvas coordinates
  _g2c: (x,y) ->
    flip = if @props.gameState.flipped then -1 else 1
    [
      flip * (x + @props.xrange / 2) * (@props.width / @props.xrange),
      (@props.height / 2) - @props.height*y/@props.yrange,
    ]

  drawDot: (context, dot) ->
    context.beginPath()
    context.arc(@_g2c(dot.x, dot.y)..., @DOT_RADIUS, 0, 2*Math.PI)
    context.lineWidth = @DOT_THICKNESS
    context.strokeStyle = if dot.active then @ACTIVE_DOT_COLOR else @DOT_COLOR
    context.stroke()

  drawText: (context, text, origin) ->
    context.font = @TEXT_FONT
    context.fillStyle = @TEXT_COLOR
    context.fillText(text, @_g2c(origin.x, origin.y)...)

  drawFunction: (context) ->
    fn = @props.gameState.fn

    context.beginPath()
    context.lineWidth = @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR

    context.moveTo(@_g2c(fn.origin.x, fn.origin.y)...)

    dx = (@props.xrange / @props.width)*1

    xMax = fn.origin.x + @FN_ANIMATION_SPEED*(@props.gameState.time - fn.startTime)

    yTranslate = fn.origin.y
    for x in [fn.origin.x .. xMax] by dx
      y = fn.evaluate(x-fn.origin.x) + yTranslate
      context.lineTo(@_g2c(x, y)...)

    context.stroke()

  render: ->
    <canvas
      style={background_color: "black"}
      width={@props.width}
      height={@props.height}
    />
)