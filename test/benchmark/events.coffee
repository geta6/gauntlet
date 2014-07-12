'use strict'

describe 'Benchmark Gauntlet.Events', ->
  Gauntlet = require __dirname + '/../../'
  Backbone = require 'backbone'
  {EventEmitter} = require 'events'

  Benchmark = require 'benchmark'
  suite = new Benchmark.Suite()
  {expect} = chai = require 'chai'

  gauntlet = new Gauntlet.Events()
  backbone = Backbone.Events
  emitter = new EventEmitter()

  chai.config.includeStack = true


  it 'should fastest', (done) ->
    suite

    .add 'Gauntlet.Events', ->
      gauntlet.on 'test1', -> 1 is 1
      gauntlet.trigger 'test1'
      gauntlet.off 'test1'

    .add 'Backbone.Events', ->
      backbone.on 'test2', -> 1 is 1
      backbone.trigger 'test2'
      backbone.off 'test2'

    .add 'EventEmitter   ', ->
      emitter.on 'test3', -> 1 is 1
      emitter.emit 'test3'
      emitter.removeAllListeners 'test3'

    .on 'cycle', (event, bench) ->
      console.log String event.target

    .on 'complete', ->
      expect(@filter('fastest').pluck('name')[0]).to.equal 'Gauntlet.Events'
      done()

    .run true
