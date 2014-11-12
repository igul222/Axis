LCDInput = require('./LCDInput.cjsx')

module.exports = React.createClass(
  displayName: 'Computer'

  handleSubmit: (e) ->
    e.preventDefault()
    @props.onSubmit?()

  render: ->
    <div>
      <div className='screen-wrapper'>
        <div className='screen-inner-wrapper'>
          {@props.content}
        </div>
      </div>

      <form id='controls' onSubmit={@handleSubmit} >
        <div id='time-remaining-wrapper'>
          <div id='time-remaining'>{@props.timeRemaining}</div>
        </div>
        <div className='expression-wrapper'>
          <LCDInput value={@props.value} onChange={@props.onValueChange} />
        </div>
        <div id='fire-wrapper'>
          <div className='huge-button-wrapper'>
            <input
              className='huge black button'
              type='submit'
              value={@props.buttonTitle}
              disabled={!@props.buttonEnabled}
            />
          </div>
        </div>
      </form>
    </div>
)