'use strict'

describe 'Gauntlet.Adaptor', ->
  Gauntlet = require __dirname + '/../'
  {expect} = chai = require 'chai'

  chai.config.includeStack = true
  server = null


  before (done) ->
    app = require __dirname + '/fixture/app'
    server = app.listen ->
      Gauntlet.Adaptor.options.port = server.address().port
      done()


  after ->
    server.close()


  it 'should have some properties', ->
    expect(Gauntlet.Adaptor).to.have.property 'exists'
    expect(Gauntlet.Adaptor).to.have.property 'select'
    expect(Gauntlet.Adaptor).to.have.property 'insert'
    expect(Gauntlet.Adaptor).to.have.property 'delete'
    expect(Gauntlet.Adaptor).to.have.property 'update'


  it 'should exists resource', (done) ->
    Gauntlet.Adaptor.exists 'user:1'
    .then (value) ->
      expect(value.status < 400).to.be.true
      expect(value.body).to.be.null
      done()
    .catch done


  it 'should select resource', (done) ->
    Gauntlet.Adaptor.select 'user:1'
    .then (value) ->
      expect(value.status < 400).to.be.true
      expect(value.body.name).to.equal 'test'
      done()
    .catch done


  it 'should insert resource', (done) ->
    Gauntlet.Adaptor.insert 'user:2', { id: 2, name: 'test2' }
    .then (value) ->
      expect(value.status < 400).to.be.true
      expect(value.body.name).to.equal 'test2'
      Gauntlet.Adaptor.select 'user:2'
      .then (value) ->
        expect(value.status < 400).to.be.true
        expect(value.body.name).to.equal 'test2'
        done()
    .catch done


  it 'should delete resource', (done) ->
    Gauntlet.Adaptor.delete 'user:2'
    .then (value) ->
      expect(value.status < 400).to.be.true
      expect(value.body).to.be.null
      Gauntlet.Adaptor.select 'user:2'
      .then (value) ->
        expect(value.status >= 400).to.be.true
        done()
    .catch done


  it 'should update resource', (done) ->
    Gauntlet.Adaptor.update 'user:1', { mail: 'test@example.com'}
    .then (value) ->
      expect(value.status < 400).to.be.true
      expect(value.body.name).to.equal 'test'
      expect(value.body.mail).to.equal 'test@example.com'
      done()
    .catch done

