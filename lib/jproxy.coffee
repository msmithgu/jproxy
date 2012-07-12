zappa = require 'zappa'

zappa ->
  @use 'bodyParser'

  @post '/:id': ->
    console.log "BODY: ", @body
    "OK #{@params.id}"

  @on connection: ->
    @emit welcome: 'hi'
