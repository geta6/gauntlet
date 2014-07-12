'use strict'

describe 'Gauntlet', ->
  Gauntlet = require __dirname + '/../'
  {expect} = chai = require 'chai'

  chai.config.includeStack = true
  pkg = require __dirname + '/../package.json'


  it 'should have some properties', ->
    expect(Gauntlet).to.have.property 'version'
    expect(Gauntlet).to.have.property 'Events'
    expect(Gauntlet).to.have.property 'Promise'

  it 'has correct version', ->
    expect(Gauntlet.version).to.equal pkg.version

