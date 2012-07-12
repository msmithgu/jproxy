zappa = require 'zappa'

zappa ->
  @post '/:id': ->
    "OK #{@params.id}"

  @on connection: ->
    @emit welcome: 'hi'
