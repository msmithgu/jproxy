zappa = require 'zappa'

zappa ->
  @get '/hello': ->
    'hi'
  @post '/post/:id': ->
    'OK foo'
