module.exports = React.createClass(
  displayName: 'SimpleLCDInput'
  mixins: [React.addons.LinkedStateMixin]
  _displayCursorChar: 'ĉ'

  getInitialState: ->
    focused: false

  handleFocus: ->
    @setState(focused: true)

  handleBlur: ->
    @setState(focused: false)

  handleChange: (e) ->
    @props.onChange?(e.target.value)

  render: ->
    <div className={React.addons.classSet(expression: true, focused: @state.focused)}>
      <div className='expression-inner-wrapper'>
        <div className='expression-background-text' ref='displayBackground' >{(@_displayCursorChar for i in [1..100]).join('')}</div>
        <input 
          className='expression-simple-input'
          type='text'
          value={@props.value}
          disabled={!@props.onChange?}
          onFocus={@handleFocus}
          onBlur={@handleBlur}
          onChange={@handleChange}
          />
      </div>
    </div>
)