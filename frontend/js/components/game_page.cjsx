Client = require('../Client.coffee')
StartedGameState = require('../../../shared/StartedGameState.coffee')
FinishedGameState = require('../../../shared/FinishedGameState.coffee')
Lobby = require('./lobby.cjsx')
Gameplay = require('./gameplay.cjsx')
FinishedScreen = require('./finished_screen.cjsx')
Chat = require('./chat.cjsx')

module.exports = React.createClass(
  displayName: 'GamePage'

  getInitialState: ->
    {sidebarActive: false}

  componentDidMount: ->
    @client = new Client(io(), @props.params.id, (data) =>
      @setState({data})
      # For debugging
      window.data = data
    )

  componentWillUnmount: ->
    @client.unsubscribe()

  toggleSidebar: ->
    @setState(sidebarActive: !@state.sidebarActive)

  pushMove: (move) ->
    @client.pushMove(move)

  render: ->
    content = if not @state.data?
      <div />
    else if @state.data.gameState instanceof StartedGameState
      <Gameplay data={@state.data} pushMove={@pushMove} />
    else if @state.data.gameState instanceof FinishedGameState
      <FinishedScreen data={@state.data} pushMove={@pushMove} />
    else
      <Lobby data={@state.data} pushMove={@pushMove} />

    sidebar = if @state.data?
      <Chat gameState={@state.data.gameState} pushMove={@pushMove} />
    else
      <div />

    <div id="wrapper" className={React.addons.classSet(active: @state.sidebarActive)} >
      <a id="sidebar-toggle" href="#" onClick={@toggleSidebar}>Toggle chat</a>
      <div id="sidebar-wrapper">
        {sidebar}
      </div>
      <div id="page-content-wrapper">
        <div className="page-content">
          <div className="container-fluid">
            {content}
          </div>
        </div>
      </div>
    </div>
)