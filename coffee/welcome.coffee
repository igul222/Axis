React = require('react/addons')

module.exports = React.createClass(
  getInitialState: ->
    name: ''
    validatesName: false

  nameChanged: (e) ->
    this.setState(name: e.target.value)

  nameBlurred: (e) ->
    this.setState(validatesName: this.state.validatesName || true)

  nameValid: ->
    this.state.name.trim() != ''

  submit: (e) ->
    e.preventDefault()

  render: ->
    cx = React.addons.classSet

    <div className="row">
      <div className="col-sm-push-3 col-sm-6">
        <div className="row">
          <div className={cx(
            'form-group': true,
            'has-error': this.state.validatesName && !this.nameValid(),
            'has-success': this.state.validatesName && this.nameValid()
            )}>
            <label className="control-label" htmlFor="name">Choose a name</label>
            <input type="text" 
              className="form-control" 
                id="name" 
                value={this.state.name}
                onBlur={this.nameBlurred} 
                onChange={this.nameChanged} />
          </div>
          <button disabled={!this.nameValid()} className="btn btn-primary">Join a game</button>
        </div>
      </div>
    </div>
)