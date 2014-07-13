'use strict'

describe 'Gauntlet', ->
  Gauntlet = require __dirname + '/../'
  {expect} = chai = require 'chai'

  chai.config.includeStack = true
  pkg = require __dirname + '/../package.json'
  bower = require __dirname + '/../bower.json'


  it 'should have some properties', ->
    expect(Gauntlet).to.have.property 'version'
    expect(Gauntlet).to.have.property 'isServer'
    expect(Gauntlet).to.have.property 'Events'
    expect(Gauntlet).to.have.property 'Promise'
    expect(Gauntlet).to.have.property 'Adaptor'

  it 'has correct version', ->
    expect(Gauntlet.version).to.equal pkg.version
    expect(Gauntlet.version).to.equal bower.version

  it 'has correct isServer', ->
    expect(Gauntlet.isServer).to.be.true
