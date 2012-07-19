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
    @channels[id]?[0] or '""'

module.exports = () ->
  return new Jdata
