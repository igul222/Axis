module.exports = React.createClass(
  displayName: 'TimeRemaining'

  render: ->
    <div id='time-remaining-wrapper'>
      <div id='time-remaining'>{@props.children}</div>
    </div>
)