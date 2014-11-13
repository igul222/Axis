module.exports = React.createClass(
  displayName: 'Button'

  handleClick: ->
    @props.onClick?()

  render: ->
    <div className='huge-button-wrapper'>
      <button
        className={'huge button '+(@props.color or 'gray')}
        disabled={@props.disabled}
        onClick={@handleClick}
      >
        {@props.title}
      </button>
    </div>
)