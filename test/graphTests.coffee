require('node-cjsx').transform()

assert = require('assert')
dom = require('./dom.coffee')

React = null
Graph = null

describe 'Graph', ->

  beforeEach =>
    dom.init()

    React = require('react/addons')
    Graph = require('../frontend/js/components/graph.cjsx')

    gameState = require('./gameState.coffee')
    @graph = React.addons.TestUtils.renderIntoDocument(
      Graph({gameState: gameState, canvasWidth: 100})
    )

  afterEach =>
    com.clean()

  describe '#_g2c', =>

    it 'should convert game coordinates to canvas coordinates', =>
      assert.deepEqual @graph._g2c(0,0), [50, 30]
      assert.deepEqual @graph._g2c(25,15), [100, 0]