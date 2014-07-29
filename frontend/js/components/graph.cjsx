React = require('react/addons')

module.exports = React.createClass(
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
    context.strokeStyle = 'rgb(255,255,255)'
    context.moveTo(0, y0) # x axis
    context.lineTo(@props.width, y0)
    context.moveTo(x0, x0) # y axis
    context.lineTo(x0, @props.height)
    context.stroke()

    for fn in @props.functions
      @drawFunction(
        context: context
        func: fn
        t: @props.t
        color: 'rgb(11,125,150)'
        thickness: 3
      )

    context.restore()
 
  drawFunction: (params) ->
    {context, func, t, color, thickness} = params

    # Define start/end points and step interval
    dx = 4
    x0 = Math.round(func.origin.x)
    xMax = Math.round((@props.width - func.origin.x) * t)

    absoluteOrigin =
      x: (@props.width / 2) + func.origin.x
      y: (@props.height / 2) - func.origin.y
    
    context.beginPath()
    context.lineWidth = thickness
    context.strokeStyle = color

    context.moveTo(absoluteOrigin.x + x0, absoluteOrigin.y + func.func(x0))

    for x in [x0..xMax] by dx
      y = func.func(x)
      context.lineTo(absoluteOrigin.x + x, absoluteOrigin.y + y)

    context.stroke()

  render: ->
    <canvas
      style={background_color: "black"}
      width={@props.width}
      height={@props.height}
    />
)