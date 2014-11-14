module.exports = React.createClass(
  displayName: "Modal"

  getInitialState: ->
    visible: false

  getDefaultProps: ->
    onShow: ->

    onHide: ->

  componentWillMount: ->
    @handleBeforeComponentUpdate @props
    return

  componentWillUnmount: ->
    @__setBodyOverflowVisible true
    return

  componentWillReceiveProps: (props) ->
    @handleBeforeComponentUpdate props
    return

  componentDidMount: ->
    @handleComponentUpdate @props, @getInitialState()
    return

  componentDidUpdate: (prevProps, prevState) ->
    @handleComponentUpdate prevProps, prevState
    return

  handleBeforeComponentUpdate: (props) ->
    @setState visible: props.visible  if props.hasOwnProperty("visible") and props.visible isnt @state.visible
    return

  handleComponentUpdate: (prevProps, prevState) ->
    if prevState.visible isnt @state.visible
      if @state.visible
        @props.onShow()
      else
        @props.onHide()
      @__setBodyOverflowVisible not @state.visible
    return

  __setBodyOverflowVisible: (visible) ->
    unless visible
      document.body.style.overflow = "hidden"
    else
      document.body.style.overflow = null
    return

  handleCloseBtnClick: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @toggleVisibility()
    return

  handleOverlayClick: (e) ->
    if e.target is @refs.overlay.getDOMNode()
      e.preventDefault()
      e.stopPropagation()
      @toggleVisibility()
    return


  # called from the outside world
  toggleVisibility: ->
    visible = not @state.visible
    @setState visible: visible
    return


  # called from the outside world
  show: ->
    @setState visible: true
    return


  # called from the outside world
  hide: ->
    @setState visible: false
    return

  render: ->
    <div 
      className={"overlay"+(if @state.visible then "" else " hidden")}
      ref="overlay"
      onClick={@handleOverlayClick}>
      <div className="overlay-top">
        <div
          className="overlay-close"
          title="Close"
          onClick={@handleCloseBtnClick}>
          x
        </div>
      </div>
      <div className="overlay-content">
        {@props.children}
      </div>
    </div>
)