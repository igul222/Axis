React = require('react/addons')

module.exports = React.createClass(
  AXIS_COLOR: 'rgb(0,0,0)'
  FUNCTION_COLOR: 'rgb(11,125,150)'
  FUNCTION_THICKNESS: 1 # 3px
  DOT_COLOR: 'rgb(150,0,0)'
  DOT_RADIUS: 10 # 10 px
  DOT_THICKNESS: 3 # 3 px

  componentDidMount: ->
    context = @getDOMNode().getContext("2d")
    @paint(context)

  componentDidUpdate: ->
    context = @getDOMNode().getContext("2d")
    context.clearRect(0, 0, @props.width, @props.height)
    @paint(context)

  paint: (context) ->
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

    #draw all dots, and their functions
    for team in @props.gameState.teams
      for player in team.players
        for dot in player.dots
          for fn in dot.functions
            @drawFunctionFromDot(context, fn, dot)
          @drawDot(context, dot)

    context.restore()
 
  # Convert graph coordinates to canvas coordinates
  _g2c: (x,y) ->
    [
      (x + @props.xrange / 2) * (@props.width / @props.xrange),
      (@props.height / 2) - @props.height*y/@props.yrange,
    ]

  drawDot: (context, dot) ->
    context.beginPath()
    context.arc(@_g2c(dot.x, dot.y)..., @DOT_RADIUS, 0, 2*Math.PI)
    context.lineWidth = @DOT_THICKNESS
    context.strokeStyle = @DOT_COLOR
    context.stroke()

  drawFunctionFromDot: (context, func, dot) ->
    # Define start/end points and step interval
    dx = (@props.xrange / @props.width)*0.01
    x0 = dot.x
    xMax = x0 + func.t*(@props.xrange/2 - dot.x)

    context.beginPath()
    context.lineWidth = @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR

    context.moveTo(@_g2c(dot.x, dot.y)...)

    yTranslate = dot.y - func.func(x0)
    for x in [x0..xMax] by dx
      y = func.func(x) + yTranslate
      context.lineTo(@_g2c(x, y)...)

    context.stroke()

  render: ->
    <canvas
      style={background_color: "black"}
      width={@props.width}
      height={@props.height}
    />
)