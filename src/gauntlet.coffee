'use strict'


class Gauntlet

  @version = '0.0.2'

  @isServer = typeof window is 'undefined'

Gauntlet.Events = require './gauntlet_events'
Gauntlet.Promise = require './gauntlet_promise'

module.exports = Gauntlet

Gauntlet.Adaptor = require './gauntlet_adaptor'
