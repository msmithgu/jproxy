io      = require 'socket.io-client'
url = 'http://localhost:3000/posts'
url = 'http://proxyhub.shrm.org:3000/posts'
posts = io.connect url

posts.on 'connecting', (tt) ->
  console.log "connecting with tt=#{tt}"
posts.on 'connect', (done) ->
  console.log "connected to #{url}"

new_posts = 0
posts.on 'new post', (data) ->
  console.log "\n### NEW POST #{++new_posts} ###"
  console.log data
