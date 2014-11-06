assert = require('assert')
seed = require('seed-random')
_ = require('lodash')

Obstacles = require('../shared/Obstacles')

describe 'Obstacles', ->

  obstacles = null

  beforeEach ->
    obstacles = new Obstacles(seed(0.5), 10, 10)

  it 'should have obstacle paths', ->
    assert obstacles.paths.length > 0
    assert obstacles.paths.every((p) -> p.length > 0)

  describe '.hitTest', ->

    it 'returns true for points within obstacle paths', ->
      # Dirty hack: to get test points within obstacles, we rely on implementation details.
      for obstacle in obstacles._obstacles
        assert obstacles.hitTest(obstacle.x, obstacle.y)

    it 'returns false for points outside obstacle paths', ->
      # Pick an x, y test point where x and y are greater than any of the points that make up
      # the obstacle paths (therefore they must be outside those paths)

      x = 1 + _(obstacles.paths).flatten().pluck('x').max()
      y = 1 + _(obstacles.paths).flatten().pluck('y').max()

      assert obstacles.hitTest(x, y) == false

    # TODO: implement this test (and rewrite all these tests to be a bit less hacky)
    it 'returns false for points within a small radius of an obstacle path'

  it 'should be able to blast a hole in an obstacle', ->
    # Same dirty hack again
    insideObstacle = obstacles._obstacles[0]
    obstacles.blast(insideObstacle.x, insideObstacle.y)
    assert obstacles.hitTest(insideObstacle.x, insideObstacle.y) == false