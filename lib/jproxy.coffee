io = require 'socket.io'
express = require 'express'
jd = require('./model')()
app = express()

app.configure () ->
  app.use express.bodyParser()

server = app.listen 3000
console.log 'http server started: http://localhost:3000/'

sio = io.listen server
sio.set 'log level', 1

sio.of('/posts')
  .on 'connection', (socket) ->
    socket.emit 'welcome', 'hi'

app.get '/posts', (req, res) ->
  res.send '"' + (jd.get_channel_ids()).join() + '"'

app.get '/posts/:id', (req, res) ->
  res.send (jd.get req.params.id)

app.post '/posts/:id', (req, res) ->
  id = req.params.id
  payload = req.body.payload
  jd.add id, payload
  res.send "OK #{id}"
  sio.of('/posts').emit 'new post', id
  sio.of("/posts/#{id}").emit 'new post', payload
