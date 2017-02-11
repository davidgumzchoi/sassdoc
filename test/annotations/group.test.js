'use strict'

var assert = require('assert')

describe('#group', function () {
  var group = (new (require('../../dist/annotation'))()).list.group

  it('should parse a single group and ingore case', function () {
    assert.deepEqual(group.parse('group'), ['group'])
    assert.deepEqual(group.parse('GRoup'), ['group'])
  })
})
