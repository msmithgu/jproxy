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
      'Content-Length': post_data.length
      'X-Github-Event': 'push'
      'Connection': 'keep-alive'
      'Accept': '*/*'
      'Content-Type': 'application/x-www-form-urlencoded'
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
  describe 'POST /foo of github mock push', ->
    it 'should respond "OK foo"', (done) ->
      mock_payload = { "after": "e4ffd72cb25e02260f34683ebcb36911a6731057", "before": "eb1e4709d072c901cc572e70f718037f54daf4c8", "commits": [ { "added": [], "author": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "committer": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "distinct": true, "id": "e4ffd72cb25e02260f34683ebcb36911a6731057", "message": "TESTFILE change", "modified": [ "TESTFILE" ], "removed": [], "timestamp": "2012-07-11T11:01:39-07:00", "url": "https://github.com/shrm-org/sherman-cda/commit/e4ffd72cb25e02260f34683ebcb36911a6731057" } ], "compare": "https://github.com/shrm-org/sherman-cda/compare/eb1e4709d072...e4ffd72cb25e", "created": false, "deleted": false, "forced": false, "head_commit": { "added": [], "author": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "committer": { "email": "Mark.Smith-Guerrero@shrm.org", "name": "Mark Smith-Guerrero", "username": "msmithgu" }, "distinct": true, "id": "e4ffd72cb25e02260f34683ebcb36911a6731057", "message": "TESTFILE change", "modified": [ "TESTFILE" ], "removed": [], "timestamp": "2012-07-11T11:01:39-07:00", "url": "https://github.com/shrm-org/sherman-cda/commit/e4ffd72cb25e02260f34683ebcb36911a6731057" }, "pusher": { "email": "msmithgu@gmail.com", "name": "msmithgu" }, "ref": "refs/heads/cda.shrm.org", "repository": { "created_at": "2012-06-26T13:07:04-07:00", "description": "Content display engine component of the Sherman CMS.", "fork": false, "forks": 0, "has_downloads": true, "has_issues": true, "has_wiki": true, "language": "CoffeeScript", "master_branch": "develop", "name": "sherman-cda", "open_issues": 1, "organization": "shrm-org", "owner": { "email": "Rodney.Waldhoff@shrm.org", "name": "shrm-org" }, "private": true, "pushed_at": "2012-07-11T11:01:44-07:00", "size": 1816, "url": "https://github.com/shrm-org/sherman-cda", "watchers": 3 } }
      postCode 'foo', mock_payload, (data) ->
        expect(data).toEqual('OK foo')
        done()

  describe 'socket connection', ->
    it 'should welcome with "hi"', (done) ->
      socket = io.connect 'http://localhost:3000'
      socket.on 'welcome', (data) ->
        expect(data).toEqual('hi')
        socket.disconnect()
        done()
