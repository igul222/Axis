require('node-cjsx').transform()

assert  = require('assert')
helpers = require('./helpers.coffee')

React = null
Graph = null

describe 'Graph', ->

  beforeEach =>
    helpers.initDOM()

    React = require('react/addons')
    Graph = require('../frontend/js/components/graph.cjsx')

    @graph = React.addons.TestUtils.renderIntoDocument(
      Graph({gameState: helpers.generateGame().state, canvasWidth: 100})
    )

  afterEach =>
    helpers.cleanDOM()

  describe '#_g2c', =>

    it 'should convert game coordinates to canvas coordinates', =>
      assert.deepEqual @graph._g2c(0,0), [50, 30]
      assert.deepEqual @graph._g2c(25,15), [100, 0]