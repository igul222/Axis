assert = require 'assert'

validateExpression = require('../shared/validateExpression.coffee')

describe.only 'validateExpression', ->

  describe 'valid expressions', ->

    it 'basic expressions', ->
      assert validateExpression('x + 1') == true

  describe 'invalid expressions', ->

    it 'unbalanced parens', ->
      assert validateExpression('(') == false

    it 'invalid variables', ->
      assert validateExpression('z') == false

    it 'SI units', ->
      assert validateExpression('s') == false