'use strict'

path = require 'path'
express = require 'express'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'

app = express()
util = require 'util'

app.use methodOverride()
app.use bodyParser.json()
app.use bodyParser.urlencoded()

resource =
  'user:1': id: 1, name: 'test'

app.head '/:key', (req, res) ->
  if resource[req.params.key]?
    res.status(200).end()
  else
    res.status(404).end()

app.get '/:key', (req, res) ->
  if resource[req.params.key]?
    res.json 200, resource[req.params.key]
  else
    res.status(404).end()

app.post '/:key', (req, res) ->
  if resource[req.params.key]?
    res.status(403).end()
  else
    resource[req.params.key] = req.body
    res.json 201, resource[req.params.key]

app.delete '/:key', (req, res) ->
  if resource[req.params.key]?
    delete resource[req.params.key]
    res.status(204).end()
  else
    res.status(404).end()

app.put '/:key', (req, res) ->
  if resource[req.params.key]?
    util._extend resource[req.params.key], req.body
    res.json 200, resource[req.params.key]
  else
    res.status(404).end()

module.exports = app
