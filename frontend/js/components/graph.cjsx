React = require('react/addons')

module.exports = React.createClass(
  AXIS_COLOR: 'rgb(0,0,0)'
  FUNCTION_COLOR: 'rgb(11,125,150)'
  FUNCTION_THICKNESS: 1 # px

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

    for fn in @props.functions
      @drawFunction(context, fn)

    context.restore()
 
  drawFunction: (context, func) ->
    # Convert graph coordinates to canvas coordinates
    g2c = (x,y) =>
      [
        (x + @props.xrange / 2) * (@props.width / @props.xrange),
        (@props.height / 2) - @props.height*y/@props.yrange,
      ]
    # Define start/end points and step interval
    dx = (@props.xrange / @props.width)*0.01
    x0 = func.origin.x
    xMax = x0 + func.t*(@props.xrange/2 - func.origin.x)

    context.beginPath()
    context.lineWidth = @FUNCTION_THICKNESS
    context.strokeStyle = @FUNCTION_COLOR

    context.moveTo(g2c(func.origin.x, func.origin.y)...)

    yTranslate = func.origin.y - func.func(x0)
    for x in [x0..xMax] by dx
      y = func.func(x) + yTranslate
      context.lineTo(g2c(x, y)...)

    context.stroke()

  render: ->
    <canvas
      style={background_color: "black"}
      width={@props.width}
      height={@props.height}
    />
)