zappa = require 'zappa'

zappa ->
  @post '/post/:id': ->
    "OK #{@params.id}"

  @on connection: ->
    @emit welcome: 'hi'
