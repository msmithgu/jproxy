qs      = require 'qs'
request = require('http').request
jproxy  = require '../lib/jproxy'
io      = require 'socket.io-client'

jreq = (options, callback) ->
  options.host    ?= 'localhost'
  options.port    ?= 3000
  options.method  ?= 'GET'
  options.path    ?= '/'

  req = request options, (res) ->
    res.setEncoding('utf8')
    # chunk (data) will be a whole string because we setEncoding
    res.on 'data', callback
  req.on 'error', (e) ->
    console.error('problem with request: ' + e.message)
  if options.data?
    req.write options.data
  req.end()

describe 'jproxy server', ->

  describe 'GET /posts/foo', ->
    it 'should respond ""', (done) ->
      jreq {path: '/posts/foo'}, (data) ->
        expect(data).toEqual('""')
        done()

  describe 'POST /posts/foo of {data: "bar"}', ->
    it 'should respond "OK foo"', (done) ->
      mock_payload = qs.stringify {data: "bar"}
      options =
        method: 'POST'
        path: "/posts/foo"
        data: mock_payload
        headers:
          'Content-Length': mock_payload.length
          'Connection': 'keep-alive'
          'Accept': '*/*'
          'Content-Type': 'application/x-www-form-urlencoded'
      jreq options, (data) ->
        expect(data).toEqual('OK foo')
        done()

    describe 'GET /posts/foo', ->
      it 'should now respond {"data":"bar"}', (done) ->
        jreq {path: '/posts/foo'}, (data) ->
          expect(data).toEqual('{"data":"bar"}')
          done()

  describe 'POST /posts/sherman-cda of github mock push', ->
    it 'should respond "OK sherman-cda"', (done) ->
      mock_payload = qs.stringify { "after": "e4ffd72cb25e02260f34683ebcb36911a6731057", "before": "eb1e4709d072c901cc572e70f718037f54daf4c8", "commits": [ { "added": [], "author": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "committer": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "distinct": true, "id": "e4ffd72cb25e02260f34683ebcb36911a6731057", "message": "TESTFILE change", "modified": [ "TESTFILE" ], "removed": [], "timestamp": "2012-07-11T11:01:39-07:00", "url": "https://github.com/shrm-org/sherman-cda/commit/e4ffd72cb25e02260f34683ebcb36911a6731057" } ], "compare": "https://github.com/shrm-org/sherman-cda/compare/eb1e4709d072...e4ffd72cb25e", "created": false, "deleted": false, "forced": false, "head_commit": { "added": [], "author": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "committer": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "distinct": true, "id": "e4ffd72cb25e02260f34683ebcb36911a6731057", "message": "TESTFILE change", "modified": [ "TESTFILE" ], "removed": [], "timestamp": "2012-07-11T11:01:39-07:00", "url": "https://github.com/shrm-org/sherman-cda/commit/e4ffd72cb25e02260f34683ebcb36911a6731057" }, "pusher": { "email": "msmithgu@gmail.com", "name": "msmithgu" }, "ref": "refs/heads/cda.shrm.org", "repository": { "created_at": "2012-06-26T13:07:04-07:00", "description": "Content display engine component of the Sherman CMS.", "fork": false, "forks": 0, "has_downloads": true, "has_issues": true, "has_wiki": true, "language": "CoffeeScript", "master_branch": "develop", "name": "sherman-cda", "open_issues": 1, "organization": "shrm-org", "owner": { "email": "Rodney.Waldhoff@shrm.org", "name": "shrm-org" }, "private": true, "pushed_at": "2012-07-11T11:01:44-07:00", "size": 1816, "url": "https://github.com/shrm-org/sherman-cda", "watchers": 3 } }
      options =
        method: 'POST'
        path: "/posts/sherman-cda"
        data: mock_payload
        headers:
          'Content-Length': mock_payload.length
          'X-Github-Event': 'push'
          'Connection': 'keep-alive'
          'Accept': '*/*'
          'Content-Type': 'application/x-www-form-urlencoded'
      jreq options, (data) ->
        expect(data).toEqual('OK sherman-cda')
        done()

  describe 'socket connection', ->
    socket = null
    beforeEach () ->
      socket = io.connect 'http://localhost:3000'

    it 'should welcome with "hi"', (done) ->
      socket.on 'welcome', (data) ->
        expect(data).toEqual('hi')
        socket.disconnect()
        done()
