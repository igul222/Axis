React  = require('react/addons')

Moves = require('../../../shared/Moves.coffee')

module.exports = React.createClass(
	mixins: [React.addons.LinkedStateMixin]

	getInitialState: ->
		message: ''

	sendMessage: (evt) ->
		evt.preventDefault()
		@props.pushMove(Moves.sendMessage(@state.message))
		@setState(message: '')

	render: ->
		messages = @props.gameState.messages.map (message) ->
			<div className="message" key={message.time}>
				<span className="sender">{message.sender}: </span>
				<span className="text">{message.text}</span>
			</div>

		<div className="chat">
			<a href="/"><img className='logo-small pull-right' src="/logo-small.png" /></a>
			<h2 className="chat-heading">MESSAGES</h2>
			<div className="chats">
				{messages}
			</div>
			<form>
				<input type="text" placeholder="type a message" valueLink={@linkState('message')} />
				<input type="submit" value="send" onClick={@sendMessage} />
			</form>
		</div>
)