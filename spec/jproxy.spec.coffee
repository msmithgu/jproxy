request = require('http').request
jproxy  = require '../lib/jproxy'

describe 'jproxy server', ->
  describe 'POST /post/foo', ->
    it 'should respond "OK foo"', (done) ->
      options =
        host: 'localhost'
        port: 3000
        path: '/post/foo'
        method: 'POST'

      req = request options, (res) ->
        # chunk will be a whole string because we setEncoding
        res.setEncoding('utf8')
        res.on 'data', (chunk) ->
          expect(chunk).toEqual('OK foo')
          done()

      req.on 'error', (e) ->
        console.log('problem with request: ' + e.message)

      req.end()
