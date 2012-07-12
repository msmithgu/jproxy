request = require('http').request
jproxy  = require '../lib/jproxy'
io      = require 'socket.io-client'

describe 'jproxy server', ->
  describe 'POST /foo of "bar"', ->
    it 'should respond "OK foo"', (done) ->
      options =
        host: 'localhost'
        port: 3000
        path: '/foo'
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

  describe 'socket connection', ->
    it 'should welcome with "hi"', (done) ->
      socket = io.connect 'http://localhost:3000'
      socket.on 'welcome', (data) ->
        expect(data).toEqual('hi')
        socket.disconnect()
        done()
