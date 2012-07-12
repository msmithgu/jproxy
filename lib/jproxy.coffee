zappa = require 'zappa'

zappa ->
  @post '/post/:id': ->
    "OK #{@params.id}"
