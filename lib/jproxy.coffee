zappa = require 'zappajs'

class Jdata
  constructor: () ->
    @config =
      post_limit: 5
    @channels = {}
  add: (id, post) ->
    @channels[id] ?= []
    @channels[id].unshift post
    if @channels[id].length > @config.post_limit
      @channels[id].pop
  get: (id) ->
    @channels[id]?[0]

jd = new Jdata

zappa ->
  @use 'bodyParser'
  @io.set 'log', false

  @post '/:id': ->
    jd.add @params.id, @body
    "OK #{@params.id}"

  @get '/:id': ->
    post = jd.get @params.id
    JSON.stringify post or ''

  @on connection: ->
    @emit welcome: 'hi'
