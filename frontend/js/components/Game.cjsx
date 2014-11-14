Client = require('../Client.coffee')

LobbyGameState = require('../../../shared/LobbyGameState.coffee')
StartedGameState = require('../../../shared/StartedGameState.coffee')

Chat = require('./Chat.cjsx')
Lobby = require('./Lobby.cjsx')
StartedGame = require('./StartedGame.cjsx')
FinishedGame = require('./FinishedGame.cjsx')

module.exports = React.createClass(
  displayName: 'Game'

  getInitialState: ->
    sidebarActive: false

  componentWillMount: ->
    @initializeClient(@props.params.id)

  componentWillUnmount: ->
    @client.unsubscribe()

  componentWillReceiveProps: (nextProps) ->
    if nextProps.params.id != @props.params.id
      @client.unsubscribe()
      @initializeClient(nextProps.params.id)

  initializeClient: (gameId) ->
    @client = new Client(io(multiplex: false), gameId, (data) =>
      @setState({data})
      # For debugging
      window.data = data
    )

  toggleSidebar: ->
    @setState(sidebarActive: !@state.sidebarActive)

  pushMove: (move) ->
    @client.pushMove(move)

  render: ->
    <div id="wrapper" className={React.addons.classSet(active: @state.sidebarActive)} >
      <a id="sidebar-toggle" href="#" onClick={@toggleSidebar}>Toggle chat</a>
      <div id="sidebar-wrapper">
        {
          if @state.data?
            <Chat gameState={@state.data.gameState} pushMove={@pushMove} />
          else
            <div />
        }
      </div>

      <div id="page-content-wrapper">
        <div className="computer-wrapper">
          {
            if not @state.data?
              <div />
            else if @state.data.gameState instanceof LobbyGameState
              <Lobby data={@state.data} pushMove={@pushMove} />
            else if @state.data.gameState instanceof StartedGameState
              <StartedGame data={@state.data} pushMove={@pushMove} />
            else
              <FinishedGame data={@state.data} pushMove={@pushMove} />
          }
        </div>
      </div>
    </div>
)