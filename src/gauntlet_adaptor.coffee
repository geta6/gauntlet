'use strict'


http = require 'http'
Gauntlet = require './gauntlet'


class Adaptor extends Gauntlet.Events

  constructor: ->
    if typeof @initialize is 'function'
      @initialize.apply this, arguments

  @options =
    hostname: 'localhost'
    port: '80'
    headers: {}

  @parse = (value) ->
    try
      return null unless value.length
      return JSON.parse value
    catch reason
      return reason

  @request = (resolve, reject, key, options = {}, senddata = '') ->
    body = ''
    parse = @parse
    @options.headers = {}
    options[k] = v for own k, v of @options
    options.path or= "/#{key}"
    options.headers['Content-Type'] or= 'application/json'
    options.headers['Content-Length'] or= senddata.length
    http.request options, (res) ->
      body = ''
      res.on 'data', (chunk) ->
        body += chunk
      res.on 'end', =>
        resolve status: res.statusCode, body: parse body
        @abort()
    .on 'error', reject
    .on 'timeout', ->
      reject new Error 'timeout'
    .end senddata, 'utf-8'

  @exists = (key, options = {}) ->
    return new Gauntlet.Promise (resolve, reject) =>
      options.method = 'HEAD'
      @request resolve, reject, key, options, ''

  @select = (key, options = {}) ->
    return new Gauntlet.Promise (resolve, reject) =>
      options.method = 'GET'
      @request resolve, reject, key, options, ''

  @insert = (key, value, options = {}) ->
    return new Gauntlet.Promise (resolve, reject) =>
      options.method = 'POST'
      @request resolve, reject, key, options, JSON.stringify value

  @delete = (key, options = {}) ->
    return new Gauntlet.Promise (resolve, reject) =>
      options.method = 'DELETE'
      @request resolve, reject, key, options, ''

  @update = (key, value, options = {}) ->
    new Gauntlet.Promise (resolve, reject) =>
      options.method = 'PUT'
      @request resolve, reject, key, options, JSON.stringify value

module.exports = Adaptor
