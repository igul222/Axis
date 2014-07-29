React = require('react/addons')
_     = require('underscore')

# {canvas, div} = React.DOM

module.exports = React.createClass(
  componentDidMount: ->
    context = @getDOMNode().getContext("2d")
    @paint context
    return

  componentDidUpdate: ->
    context = @getDOMNode().getContext("2d")
    context.clearRect 0, 0, @props.width, @props.height
    @paint context
    return

  paint: (context) ->
    axes = undefined
    width = undefined
    height = undefined
    t = undefined
    t = @props.t
    width = @props.width
    height = @props.height
    context.save
    
    axes =
      x0: 0.5 * @props.width
      y0: 0.5 * @props.height
      doNegativeX: true

    @drawAxes context, axes
    drawFunc = @drawFunc
    @props.equations.forEach (value, index) ->
      drawFunc context, value.equation, value.origin, t, "rgb(11,125,150)", 3
      return

    return
 
  drawFunc: (context, func, origin, t, color, thickness) ->
    dx = undefined
    i = undefined
    iMax = undefined
    iMin = undefined
    x = undefined
    y = undefined
    dx = 4
    iMax = Math.round((@props.width - origin.x) / dx * (t / 1.0))
    absoluteOrigin =
      x: (@props.width / 2) + origin.x
      y: (@props.height / 2) - origin.y

    sign = (x) ->
      (if typeof x is "number" then (if x then (if x < 0 then -1 else 1) else (if x is x then 0 else NaN)) else NaN)

    iMin = Math.round(sign(origin.x) * (origin.x) / dx)
    
    context.beginPath()
    context.lineWidth = thickness
    context.strokeStyle = color
    i = iMin
    while i <= iMax
      
      x = dx * (i - iMin)
      y = func(x)
      if i is iMin
        context.moveTo absoluteOrigin.x + x, absoluteOrigin.y + y
      else
        context.lineTo absoluteOrigin.x + x, absoluteOrigin.y + y
      i++
    context.stroke()
    return

  drawAxes: (context, axes) ->
    h = undefined
    w = undefined
    x0 = undefined
    xmin = undefined
    y0 = undefined
    x0 = axes.x0
    y0 = axes.y0
    w = @props.width
    h = @props.height
    xmin = ((if axes.doNegativeX then 0 else x0))
    context.beginPath()
    context.strokeStyle = "rgb(255,255,255)"
    context.moveTo xmin, y0 #x axis
    context.lineTo w, y0
    context.moveTo x0, 0 #y axis
    context.lineTo x0, h
    context.stroke()
    return

  render: ->
    <canvas style={background_color: "black"} width = 800 height = 800 />
)