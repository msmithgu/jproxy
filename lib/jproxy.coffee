zappa = require 'zappa'

zappa ->
  @use 'bodyParser'
  @io.set 'log', false

  @post '/:id': ->
    console.log "BODY: ", @body
    "OK #{@params.id}"

  @on connection: ->
    @emit welcome: 'hi'
