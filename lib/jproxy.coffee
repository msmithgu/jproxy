io = require 'socket.io'
express = require 'express'
jd = require('./model')()
app = express()

app.configure () ->
  app.use express.bodyParser()

app.get '/posts/:id', (req, res) ->
  res.send (jd.get req.params.id)

app.post '/posts/:id', (req, res) ->
  jd.add req.params.id, req.body
  res.send "OK #{req.params.id}"

server = app.listen 3000
console.log 'http server started: http://localhost:3000/'

sio = io.listen server
sio.sockets.on 'connection', (socket) ->
  socket.emit 'welcome', 'hi'
