module.exports = React.createClass(
  displayName: 'FinishedScreen'

  endStatus: ->
    if @props.data.gameState.players.isWinner(@props.data.playerId)
      "YOU WIN!"
    else
      "YOU LOSE."
    
  joinPublicGame: (e) ->
    e.preventDefault()
    r = new XMLHttpRequest()
    r.open('POST', '/joinPublicGame', true)
    r.onreadystatechange = ->
      return unless r.readyState == 4 and r.status == 200
      page('/games/'+ r.responseText)
    r.send()

  render: ->
    <div>
      <div id='canvas-wrapper'>
        <div id="finished-screen-text">
          {@endStatus()}
        </div>
      </div>

      <form id='controls'>

        <div id='time-remaining-wrapper'>
          <div id='time-remaining'></div>
        </div>

        <div id='expression-wrapper'>
          <div id='expression'>
            <input type = "text" value = "press any key to play again" />
            <div id='lcd-background'>ĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉĉ</div>
          </div>
        </div>

        <div id='fire-wrapper'>
          <div className='huge-button-wrapper'>
            <input
              className='huge black button'
              value='FIRE'
            />
          </div>
        </div>

      </form>
    </div>
)