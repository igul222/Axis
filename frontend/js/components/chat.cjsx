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
			<li className="message" key={message.time}>
				<div className="sender">{message.sender}</div>
				<div className="text">{message.text}</div>
			</li>

		<div>
			<div className="heading">Chat</div>
			<div className="chats">
				<ol className="messageList">
					{messages}
				</ol>
			</div>
			<form id="chatbox">
				<input type="text" placeholder="type a message" valueLink={@linkState('message')} />
				<input type="submit" value="send" onClick={@sendMessage} />
			</form>
		</div>
)