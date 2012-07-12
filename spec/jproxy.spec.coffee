qs      = require 'qs'
request = require('http').request
jproxy  = require '../lib/jproxy'
io      = require 'socket.io-client'

postCode = (id, obj, callback) ->
  # Build the post string from an object
  post_data = qs.stringify obj

  post_options =
    host: 'localhost'
    port: 3000
    path: "/#{id}"
    method: 'POST'
    headers:
      'Content-Type': 'application/x-www-form-urlencoded'
      'Content-Length': post_data.length
  post_req = request post_options, (res) ->
    res.setEncoding('utf8')
    # chunk (data) will be a whole string because we setEncoding
    res.on 'data', callback
  post_req.on 'error', (e) ->
    console.error('problem with request: ' + e.message)
  # post the data
  post_req.write post_data
  post_req.end()

describe 'jproxy server', ->
  describe 'POST /foo of "bar"', ->
    it 'should respond "OK foo"', (done) ->
      postCode 'foo', {mydata: 'foo'}, (data) ->
        expect(data).toEqual('OK foo')
        done()

  describe 'socket connection', ->
    it 'should welcome with "hi"', (done) ->
      socket = io.connect 'http://localhost:3000'
      socket.on 'welcome', (data) ->
        expect(data).toEqual('hi')
        socket.disconnect()
        done()
