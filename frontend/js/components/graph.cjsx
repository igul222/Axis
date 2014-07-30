React = require('react/addons')

module.exports = React.createClass(
  AXIS_COLOR: 'rgb(0,0,0)'
  FUNCTION_COLOR: 'rgb(11,125,150)'
  FUNCTION_THICKNESS: 1 # 3px

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
      @drawFunction(
        context: context
        func: fn
        t: @props.t
        color: @FUNCTION_COLOR
        thickness: @FUNCTION_THICKNESS
      )

    context.restore()
 
  drawFunction: (params) ->
    {context, func, t, color, thickness} = params

    # Convert graph coordinates to canvas coordinates
    g2c = (x,y) =>
      [
        (x + @props.xrange / 2) * (@props.width / @props.xrange),
        @props.height - ((y + @props.yrange / 2) * (@props.height / @props.yrange)),
      ]

    # Define start/end points and step interval
    dx = (@props.xrange / @props.width)
    x0 = func.origin.x
    xMax = x0 + t*(@props.xrange/2 - func.origin.x)

    context.beginPath()
    context.lineWidth = thickness
    context.strokeStyle = color

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