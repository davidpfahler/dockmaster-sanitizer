'use strict'

Sanitizer = require '../lib/Sanitizer'
fs = require 'fs'

exports['sanitizer'] =
  'workorders': (test) ->
    test.expect 1

    raw       = require '../test/fixtures/workorders.json'
    expected  = JSON.stringify require '../test/expected/workorders.json'
    actual    = ''
    sanitizer = new Sanitizer

    sanitizer.on 'data', (chunk) ->
      actual += chunk.toString 'utf8'

    sanitizer.on 'end', ->
      test.deepEqual actual, expected, 'Workorders parsed correctly'
      test.done()

    sanitizer.write raw
    sanitizer.end()

  'emptyWorkorders': (test) ->
    test.expect 1

    raw       = require '../test/fixtures/emptyWorkorders.json'
    expected  = JSON.stringify require '../test/expected/emptyWorkorders.json'
    actual    = ''
    sanitizer = new Sanitizer

    sanitizer.on 'data', (chunk) ->
      actual += chunk.toString 'utf8'

    sanitizer.on 'end', ->
      test.deepEqual actual, expected, 'empty workorders parsed correctly'
      test.done()

    sanitizer.write raw
    sanitizer.end()
