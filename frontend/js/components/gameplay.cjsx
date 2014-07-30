React = require('react/addons')
Graph = require('./graph.cjsx')

module.exports = React.createClass(
  getInitialState: ->
    t: 0
    width: 800
    height: 800

  componentDidMount: ->
    requestAnimationFrame @tick

  tick: ->
    @setState t: @state.t + .005
    requestAnimationFrame @tick

  render: ->
    <Graph t={@state.t} functions={[
        {
          func: (x) -> 10 * Math.sin(x / 10)
          origin:
            x: -275
            y: 275
        }
        {
          func: (x) ->
            0.4*x*Math.sin(x/2)
          
          origin:
            x: -275
            y: 15
        }
      ]}
      width = {@state.width}
      height = {@state.height} />
)