'use strict'

describe 'Gauntlet.Events', ->
  Gauntlet = require __dirname + '/../'
  {expect} = chai = require 'chai'

  chai.config.includeStack = true


  it 'should have some properties', ->
    expect(Gauntlet.Events.prototype).to.have.property 'listeners'
    expect(Gauntlet.Events.prototype).to.have.property 'trigger'
    expect(Gauntlet.Events.prototype).to.have.property 'on'
    expect(Gauntlet.Events.prototype).to.have.property 'once'
    expect(Gauntlet.Events.prototype).to.have.property 'off'


  it 'inheritable prototypes', ->
    Beast = -> return
    require('util').inherits Beast, Gauntlet.Events

    moop = new Beast()
    meap = new Beast()

    expect(moop).to.be.instanceOf Beast
    expect(moop).to.be.instanceof Gauntlet.Events

    moop.on 'data', ->
      throw new Error 'I should not trigger'

    meap.trigger 'data', 'rawr'
    meap.off 'foo'
    meap.off()



  describe 'Gauntlet.Events::trigger', ->
    it 'should return false when there are not events to trigger', ->
      e = new Gauntlet.Events()

      expect(e.trigger 'foo').to.equal false
      expect(e.trigger 'bar').to.equal false


    it 'triggers with context', (done) ->
      e = new Gauntlet.Events()
      context = 'bar'

      e.on 'foo', (bar) ->
        expect(bar).to.equal 'bar'
        expect(this).to.equal context
        process.nextTick -> done()
      , context
      e.trigger 'foo', 'bar'


    it 'should return true when there are events to trigger', (done) ->
      e = new Gauntlet.Events()

      e.on 'foo', -> process.nextTick done

      expect(e.trigger 'foo').to.equal true
      expect(e.trigger 'foob').to.equal false


    it 'receives the triggered events with 2 args', (done) ->
      e = new Gauntlet.Events()

      args = ['foo', e]
      e.on 'data', (a, b, undef) ->
        expect(a).to.equal 'foo'
        expect(b).to.equal e
        expect(undef).to.equal undefined
        expect(arguments.length).to.equal 2
        done()
      e.trigger 'data', args[0], args[1]


    it 'receives the triggered events with 3 args', (done) ->
      e = new Gauntlet.Events()

      args = ['foo', e, new Date()]
      e.on 'data', (a, b, c, undef) ->
        expect(a).to.equal 'foo'
        expect(b).to.equal e
        expect(c).to.be.instanceOf Date
        expect(undef).to.equal undefined
        expect(arguments.length).to.equal 3
        done()
      e.trigger 'data', args[0], args[1], args[2]


    it 'receives the triggered events with 4 args', (done) ->
      e = new Gauntlet.Events()

      args = ['foo', e, new Date(), {}]
      e.on 'data', (a, b, c, d, undef) ->
        expect(a).to.equal 'foo'
        expect(b).to.equal e
        expect(c).to.be.instanceOf Date
        expect(d).to.equal args[3]
        expect(undef).to.equal undefined
        expect(arguments.length).to.equal 4
        done()
      e.trigger 'data', args[0], args[1], args[2], args[3]


    it 'receives the triggered events with 5 args', (done) ->
      ev = new Gauntlet.Events()

      args = ['foo', ev, new Date(), {}, []]
      ev.on 'data', (a, b, c, d, e, undef) ->
        expect(a).to.equal 'foo'
        expect(b).to.equal ev
        expect(c).to.be.instanceOf Date
        expect(d).to.equal args[3]
        expect(e).to.equal args[4]
        expect(undef).to.equal undefined
        expect(arguments.length).to.equal 5
        done()
      ev.trigger 'data', args[0], args[1], args[2], args[3], args[4]


    it 'receives the triggered events with over 6 args', (done) ->
      ev = new Gauntlet.Events()

      args = ['foo', ev, new Date(), {}, [], 'bar']
      ev.on 'data', (a, b, c, d, e, f, undef) ->
        expect(a).to.equal 'foo'
        expect(b).to.equal ev
        expect(c).to.be.instanceOf Date
        expect(d).to.equal args[3]
        expect(e).to.equal args[4]
        expect(f).to.equal 'bar'
        expect(undef).to.equal undefined
        expect(arguments.length).to.equal 6
        done()
      ev.trigger 'data', args[0], args[1], args[2], args[3], args[4], args[5]


    it 'triggers to all event listeners', ->
      e = new Gauntlet.Events()
      pattern = []

      e.on 'foo', -> pattern.push 'foo1'
      e.on 'foo', -> pattern.push 'foo2'
      e.trigger 'foo'

      expect(pattern.join ';').to.equal 'foo1;foo2'



  describe 'Gauntlet.Events::listeners', ->
    it 'returns an empty array if no listeners are specified', ->
      e = new Gauntlet.Events()

      expect(e.listeners 'foo').to.be.a 'array'
      expect(e.listeners('foo').length).to.equal 0


    it 'returns an array of function', ->
      e = new Gauntlet.Events()

      e.on 'foo', foo = -> return

      expect(e.listeners 'foo').to.be.a 'array'
      expect(e.listeners('foo').length).to.equal 1
      expect(e.listeners 'foo').to.deep.equal [foo]

    it 'is not vulnerable to modifications', ->
      e = new Gauntlet.Events()

      e.on 'foo', foo = -> return

      expect(e.listeners 'foo').to.deep.equal [foo]
      e.listeners('foo').length = 0
      expect(e.listeners 'foo').to.deep.equal [foo]



  describe 'Gauntlet.Events::once', ->
    it 'only triggers it once', ->
      e = new Gauntlet.Events()
      calls = 0

      e.once 'foo', -> calls++
      e.trigger 'foo' for i in [0...10]

      expect(e.listeners('foo').length).to.equal 0
      expect(calls).to.equal 1


    it 'only triggers once if triggers are nested inside the listener', ->
      e = new Gauntlet.Events()
      calls = 0

      e.once 'foo', ->
        calls++
        e.trigger 'foo'
      e.trigger 'foo'

      expect(e.listeners('foo').length).to.equal 0
      expect(calls).to.equal 1


    it 'only triggers once for multiple events', ->
      e = new Gauntlet.Events()
      [multi, foo, bar] = [0, 0, 0]

      e.once 'foo', -> foo++
      e.once 'foo', -> bar++
      e.on 'foo', -> multi++
      e.trigger 'foo' for i in [0...5]

      expect(e.listeners('foo').length).to.equal 1
      expect(multi).to.equal 5
      expect(foo).to.equal 1
      expect(bar).to.equal 1


    it 'only triggers once with context', (done) ->
      e = new Gauntlet.Events()
      context = 'foo'

      e.once 'foo', (bar) ->
        expect(this).to.equal context
        expect(bar).to.equal 'bar'
        done()
      , context
      e.trigger 'foo', 'bar'



  describe 'Gauntlet.Events::off', ->
    it 'should only remove the event with the specified function', ->
      e = new Gauntlet.Events()

      e.on 'foo', -> return
      e.on 'bar', -> return
      e.on 'bar', bar = -> return

      expect(e.off 'foo', bar).to.equal e
      expect(e.listeners('foo').length).to.equal 1
      expect(e.listeners('bar').length).to.equal 2

      expect(e.off 'foo').to.equal e
      expect(e.listeners('foo').length).to.equal 0
      expect(e.listeners('bar').length).to.equal 2

      expect(e.off 'bar', bar).to.equal e
      expect(e.listeners('bar').length).to.equal 1
      expect(e.off 'bar').to.equal e
      expect(e.listeners('bar').length).to.equal 0

    it 'removes all events for the specified events', ->
      e = new Gauntlet.Events()

      e.on 'foo', -> throw new Error 'oops'
      e.on 'foo', -> throw new Error 'oops'
      e.on 'bar', -> throw new Error 'oops'
      e.on 'aaa', -> throw new Error 'oops'

      expect(e.off 'foo').to.equal e
      expect(e.listeners('foo').length).to.equal 0
      expect(e.listeners('bar').length).to.equal 1
      expect(e.listeners('aaa').length).to.equal 1

      expect(e.off 'bar').to.equal e
      expect(e.off 'aaa').to.equal e

      expect(e.trigger 'foo').to.equal false
      expect(e.trigger 'bar').to.equal false
      expect(e.trigger 'aaa').to.equal false


    it 'just nukes the fuck out of everything', ->
      e = new Gauntlet.Events()

      e.on 'foo', -> throw new Error 'oops'
      e.on 'foo', -> throw new Error 'oops'
      e.on 'bar', -> throw new Error 'oops'
      e.on 'aaa', -> throw new Error 'oops'

      expect(e.off()).to.equal e
      expect(e.listeners('foo').length).to.equal 0
      expect(e.listeners('bar').length).to.equal 0
      expect(e.listeners('aaa').length).to.equal 0

      expect(e.trigger 'foo').to.equal false
      expect(e.trigger 'bar').to.equal false
      expect(e.trigger 'aaa').to.equal false
