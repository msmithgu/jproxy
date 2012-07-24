require '../lib/jproxy'
qs      = require 'qs'
request = require('http').request
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

  last_post_id = ''
  latest_posts = {}
  posts = null

  describe 'posts socket', ->
    posts = io.connect 'http://localhost:3000/posts'

    it 'should connect', (done) ->
      posts.on 'connect', () ->
        done()

    posts.on 'new post', (data) ->
      last_post_id = data.id
      latest_posts[data.id] = data.post

  describe 'GET /', ->
    it 'should respond with "hi"', (done) ->
      jreq {path: '/'}, (data) ->
        expect(data).toEqual('hi')
        done()

  describe 'POST /posts/foo of {"data":"bar"}', ->
    mock_data = '{"data": "bar"}'
    mock_payload = qs.stringify { payload: mock_data }
    it 'should respond "OK foo"', (done) ->
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
    it 'should trigger new post socket event', (done) ->
      expect(last_post_id).toEqual('foo')
      expect(latest_posts['foo']).toEqual(mock_data)
      done()

    describe 'GET /posts/foo', ->
      it "should now respond #{mock_data}", (done) ->
        jreq {path: '/posts/foo'}, (data) ->
          expect(typeof data).toEqual('string')
          expect(data).toEqual(mock_data)
          done()

  describe 'POST /posts/jproxy of mock github push', ->
    mock_data = '{"pusher":{"name":"none"},"repository":{"name":"jproxy","has_wiki":true,"size":340,"created_at":"2012-07-12T10:45:29-07:00","private":false,"watchers":1,"language":"CoffeeScript","url":"https://github.com/msmithgu/jproxy","fork":false,"pushed_at":"2012-07-21T21:17:47-07:00","has_downloads":true,"open_issues":0,"has_issues":true,"forks":1,"description":"","owner":{"name":"msmithgu","email":"msmithgu@gmail.com"}},"forced":false,"after":"b5fa9392cefe10428301831ca2ec4b7096af2c7d","head_commit":{"added":[],"modified":["README.md"],"removed":[],"author":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"},"timestamp":"2012-07-21T21:17:42-07:00","url":"https://github.com/msmithgu/jproxy/commit/b5fa9392cefe10428301831ca2ec4b7096af2c7d","id":"b5fa9392cefe10428301831ca2ec4b7096af2c7d","distinct":true,"message":"added npm install . to README","committer":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"}},"deleted":false,"commits":[{"added":[],"modified":["spec/jproxy.spec.coffee"],"removed":[],"author":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"},"timestamp":"2012-07-21T10:43:54-07:00","url":"https://github.com/msmithgu/jproxy/commit/6ad17701e5f21d2816583cdffad077532144e37a","id":"6ad17701e5f21d2816583cdffad077532144e37a","distinct":true,"message":"adjusted posts welcome test to work better asynchronously","committer":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"}},{"added":[],"modified":["README.md"],"removed":[],"author":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"},"timestamp":"2012-07-21T11:09:17-07:00","url":"https://github.com/msmithgu/jproxy/commit/548ca6fc1eae9fcaa4d17c9b834ab5c512f256b6","id":"548ca6fc1eae9fcaa4d17c9b834ab5c512f256b6","distinct":true,"message":"made readme dev setup instructions copy/pastable","committer":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"}},{"added":[],"modified":["README.md"],"removed":[],"author":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"},"timestamp":"2012-07-21T21:17:42-07:00","url":"https://github.com/msmithgu/jproxy/commit/b5fa9392cefe10428301831ca2ec4b7096af2c7d","id":"b5fa9392cefe10428301831ca2ec4b7096af2c7d","distinct":true,"message":"added npm install . to README","committer":{"name":"Mark Smith-Guerrero","username":"msmithgu","email":"msmithgu@gmail.com"}}],"ref":"refs/heads/master","compare":"https://github.com/msmithgu/jproxy/compare/4aee9e9bd8dc...b5fa9392cefe","before":"4aee9e9bd8dca890e1bb01cb240418ec5d2dc73a","created":false}'
    mock_payload = qs.stringify { payload: mock_data }
    it 'should respond "OK jproxy"', (done) ->
      options =
        method: 'POST'
        path: "/posts/jproxy"
        data: mock_payload
        headers:
          'Content-Length': mock_payload.length
          'X-Github-Event': 'push'
          'Connection': 'keep-alive'
          'Accept': '*/*'
          'Content-Type': 'application/x-www-form-urlencoded'
      jreq options, (data) ->
        expect(data).toEqual('OK jproxy')
        done()
    it 'should trigger new post socket event with correct id and post data', (done) ->
      expect(last_post_id).toEqual('jproxy')
      expect(latest_posts['jproxy']).toEqual(mock_data)
      done()
    describe 'received data', ->
      it 'should be JSON parse-able and thereby accessible', (done) ->
        data = JSON.parse(latest_posts['jproxy'])
        console.log data
        expect(data.ref).toEqual('refs/heads/master')
        expect(data.after).toEqual('b5fa9392cefe10428301831ca2ec4b7096af2c7d')
        done()

    describe 'GET /posts/jproxy', ->
      it 'should now respond with the mock github push', (done) ->
        jreq {path: '/posts/jproxy'}, (data) ->
          expect(typeof data).toEqual('string')
          expect(data).toEqual(mock_data)
          done()

  describe 'posts socket', ->
    it 'should disconnect cleanly', (done) ->
      posts.on 'disconnect', () ->
        done()
      posts.disconnect()
