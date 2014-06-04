React = require('react')

module.exports = React.createClass(
  getInitialState: ->
    name: ''

  render: ->
    <form>
      <div className="form-group">
        <label htmlFor="name">Choose a name</label>
        <input type="text" class="form-control" id="name" />
      </div>
      <button type="submit" className="btn btn-default">Submit</button>
    </form>
)