'use strict'

describe 'Gauntlet.Promise', ->
  Gauntlet = require __dirname + '/../'
  {expect} = chai = require 'chai'

  chai.config.includeStack = true


  it 'should have some properties', ->
    expect(Gauntlet.Promise).to.have.property 'resolve'
    expect(Gauntlet.Promise).to.have.property 'reject'
    expect(Gauntlet.Promise).to.have.property 'all'
    expect(Gauntlet.Promise).to.have.property 'race'
    expect(Gauntlet.Promise.prototype).to.have.property 'then'
    expect(Gauntlet.Promise.prototype).to.have.property 'catch'


  it 'should be a constructor and constructor should have length 1', ->
    promise = new Gauntlet.Promise -> return
    expect(Object.getPrototypeOf promise).to.equal Gauntlet.Promise.prototype
    expect(promise.constructor).to.equal Gauntlet.Promise
    expect(Gauntlet.Promise::constructor).to.equal Gauntlet.Promise
    expect(Gauntlet.Promise.length).to.equal 1


  it 'should fulfill if `resolve` is called with a value', (done) ->
    value = 'value'
    promise = new Gauntlet.Promise (resolve) ->
      resolve value
    promise.then (v) ->
      expect(v).to.equal value
      done()


  it 'should reject if `reject` is called with a reason', (done) ->
    reason = 'reason'
    promise = new Gauntlet.Promise (resolve, reject) ->
      reject reason
    promise.then ->
      expect(false).to.be.equal true, 'should not call me'
      done()
    , (r) ->
      expect(r).to.equal reason
      done()


  it 'should NOT work without `new`', ->
    expect(-> Gauntlet.Promise -> return).to.throw TypeError


  it 'should NOT work without a function', ->
    expect(-> new Gauntlet.Promise()).to.throw TypeError
    expect(-> new Gauntlet.Promise {}).to.throw TypeError
    expect(-> new Gauntlet.Promise 'foo').to.throw TypeError


  it 'should reject on resolver exception', (done) ->
    error = new Error 'error'
    new Gauntlet.Promise ->
      throw error
    .then null, (reason) ->
      expect(reason).to.equal error
      done()


  it 'should not resolve multiple times', (done) ->
    resolved = 0
    rejected = 0
    resolver = undefined
    rejector = undefined
    thenable = then: (resolve, reject) ->
      resolver = resolve
      rejector = reject
    promise = new Gauntlet.Promise (resolve) ->
      resolve 1
    promise.then (value) -> thenable
    promise.then (value) -> resolved++
    promise.catch (reason) -> rejected++
    setTimeout ->
      resolver i for i in [1, 1]
      rejector i for i in [1, 1]
      setTimeout ->
        expect(resolved).to.equal 1
        expect(rejected).to.equal 0
        done()
      , 10
    , 10


  it 'should assimilate `resolve` with a resolved promise', (done) ->
    origin = new Gauntlet.Promise (resolve) ->
      resolve 'original value'
    promise = new Gauntlet.Promise (resolve) ->
      resolve origin
    promise.then (value) ->
      expect(value).to.equal 'original value'
      done()


  it 'should assimilate `resolve` with a rejected promise', (done) ->
    origin = new Gauntlet.Promise (resolve, reject) ->
      reject 'original reason'
    promise = new Gauntlet.Promise (resolve) ->
      resolve origin
    promise.then ->
      expect(false).to.be.equal true, 'should not call me'
      done()
    , (reason) ->
      expect(reason).to.equal 'original reason'
      done()


  it 'should assimilate `resolve` with a rejected thenable', (done) ->
    origin = then: (onResolved, onRejected) ->
      setTimeout (-> onRejected 'original reason'), 0
    promise = new Gauntlet.Promise (resolve) ->
      resolve origin
    promise.then ->
      expect(false).to.be.equal true, 'should not call me'
      done()
    , (reason) ->
      expect(reason).to.equal 'original reason'
      done()


  it 'should assimilate 2 levels, for resolution of self promises', (done) ->
    origin = new Gauntlet.Promise (resolve) ->
      setTimeout (-> resolve origin), 0
    promise = new Gauntlet.Promise (resolve) ->
      setTimeout (-> resolve origin), 0
    promise.then (value) ->
      expect(value).to.equal origin
      done()


  it 'should assimilate 2 levels, for resolution', (done) ->
    origin = new Gauntlet.Promise (resolve) ->
      resolve 'original value'
    next = new Gauntlet.Promise (resolve) ->
      resolve origin
    promise = new Gauntlet.Promise (resolve) ->
      resolve next
    promise.then (value) ->
      expect(value).to.equal 'original value'
      done()


  it 'should assimilate 2 levels, for rejection', (done) ->
    origin = new Gauntlet.Promise (resolve, reject) ->
      reject 'original reason'
    next = new Gauntlet.Promise (resolve) ->
      resolve origin
    promise = new Gauntlet.Promise (resolve) ->
      resolve next
    promise.then ->
      expect(false).to.be.equal true, 'should not call me'
      done()
    , (reason) ->
      expect(reason).to.equal 'original reason'
      done()


  it 'should assimilate 3 levels, for resolution of mixing objects', (done) ->
    origin = new Gauntlet.Promise (resolve) ->
      resolve 'original value'
    intermediate = then: (onResolved) ->
      setTimeout (-> onResolved origin), 0
    promise = new Gauntlet.Promise (resolve) ->
      resolve intermediate
    promise.then (value) ->
      expect(value).to.equal 'original value'
      done()


  it 'should assimilate 3 levels, for rejection of mixing objects', (done) ->
    origin = new Gauntlet.Promise (resolve, reject) ->
      reject 'original reason'
    intermediate = then: (onResolved) ->
      setTimeout (-> onResolved origin), 0
    promise = new Gauntlet.Promise (resolve) ->
      resolve intermediate
    promise.then ->
      expect(false).to.be.equal true, 'should not call me'
      done()
    , (reason) ->
      expect(reason).to.equal 'original reason'
      done()


  it 'should return same promise if circular promised', ->
    promise = Gauntlet.Promise.resolve 1
    wrapped = Gauntlet.Promise.resolve promise
    expect(wrapped).to.be.equal promise


  it 'should return resolved promise if thenable promised', ->
    promise = then: -> return
    wrapped = Gauntlet.Promise.resolve promise
    expect(wrapped).to.be.instanceof Gauntlet.Promise
    expect(wrapped).to.not.equal promise


  it 'should return resolved promise if subclass promised', (done) ->
    class ExtendedPromise extends Gauntlet.Promise
    promise = Gauntlet.Promise.resolve 1
    wrapped = ExtendedPromise.resolve promise
    expect(wrapped).to.be.instanceof Gauntlet.Promise
    expect(wrapped).to.be.instanceof ExtendedPromise
    expect(wrapped).to.not.equal promise
    wrapped.then (value) ->
      expect(value).to.be.equal 1
      done()


  it 'should return resolved promise', ->
    value = 1
    wrapped = Gauntlet.Promise.resolve value
    expect(wrapped).to.be.instanceof Gauntlet.Promise
    expect(wrapped).to.not.equal value


  it 'should casts null correctly', (done) ->
    Gauntlet.Promise.resolve null
    .then (value) ->
      expect(value).to.be.null
      done()
    .catch (reason) ->
      expect(false).to.be.true



  describe 'Gauntlet.Promise.all', ->
    it 'should NOT work without an array', ->
      expect(-> Gauntlet.Promise.all()).to.throw TypeError
      expect(-> Gauntlet.Promise.all '').to.throw TypeError
      expect(-> Gauntlet.Promise.all {}).to.throw TypeError


    it 'should resolved only after all of the promises are resolved', (done) ->
      resolves = []
      resolvers = []
      first = new Gauntlet.Promise (resolve) ->
        resolvers[0] = resolve
      first.then ->
        resolves[0] = true
      second = new Gauntlet.Promise (resolve) ->
        resolvers[1] = resolve
      second.then ->
        resolves[1] = true
      setTimeout (-> resolvers[0] true), 0
      setTimeout (-> resolvers[1] true), 0
      Gauntlet.Promise.all([first, second]).then ->
        expect(resolves[0]).to.be.true
        expect(resolves[1]).to.be.true
        done()


    it 'should rejected as soon as a promise is rejected', (done) ->
      resolvers = []
      rejected = undefined
      completed = undefined
      first = new Gauntlet.Promise (resolve, reject) ->
        resolvers[0] = { resolve, reject }
      second = new Gauntlet.Promise (resolve, reject) ->
        resolvers[1] = { resolve, reject }
      setTimeout (-> resolvers[0].reject {}), 0
      first.catch ->
        rejected = true
      second.then ->
        completed = true
      second.catch (reason) ->
        completed = true
        throw reason
      Gauntlet.Promise.all [first, second]
      .then ->
        expect(false).to.be.equal true, 'should not call me'
      .catch ->
        expect(rejected).to.be.true
        expect(completed).to.not.be.true
        done()


    it 'should passes the resolved values to callback with order', (done) ->
      resolvers = []
      first = new Gauntlet.Promise (resolve, reject) ->
        resolvers[0] = { resolve, reject }
      second = new Gauntlet.Promise (resolve, reject) ->
        resolvers[1] = { resolve, reject }
      third = new Gauntlet.Promise (resolve, reject) ->
        resolvers[2] = { resolve, reject }
      resolvers[2].resolve 3
      resolvers[0].resolve 1
      resolvers[1].resolve 2
      Gauntlet.Promise.all [first, second, third]
      .then (results) ->
        expect(results.length).to.equal 3
        expect(results[0]).to.equal 1
        expect(results[1]).to.equal 2
        expect(results[2]).to.equal 3
        done()


    it 'should resolves an empty array passed to `all`', (done) ->
      Gauntlet.Promise.all([]).then (results) ->
        expect(results.length).to.equal 0
        done()


    it 'should works with null', (done) ->
      Gauntlet.Promise.all([null]).then (results) ->
        expect(results[0]).to.be.null
        done()


    it 'should works with a mixing objects and non-promises', (done) ->
      promise = new Gauntlet.Promise (resolve) -> resolve 1
      sync = then: (onResolved) -> onResolved 2
      async = then: (onResolved) -> setTimeout (-> onResolved 3), 0
      noop = 4
      Gauntlet.Promise.all([promise, sync, async, noop]).then (results) ->
        expect(results).to.deep.equal [1, 2, 3, 4]
        done()



  describe 'Gauntlet.Promise.reject', ->
    it 'should rejects', ->
      reason = 'the reason'
      Gauntlet.Promise.reject reason
      .then ->
        expect(false).to.be.equal true, 'should not call me'
      .catch (actual) ->
        expect(actual).to.be.equal reason



  describe 'Gauntlet.Promise.race', ->
    it 'should NOT work without an array', ->
      expect(-> Gauntlet.Promise.race()).to.throw TypeError
      expect(-> Gauntlet.Promise.race '').to.throw TypeError
      expect(-> Gauntlet.Promise.race {}).to.throw TypeError


    it 'should resolved after one of the promise is resolved', (done) ->
      resolves = []
      resolvers = []
      first = new Gauntlet.Promise (resolve) ->
        resolvers[0] = resolve
      first.then ->
        resolves[0] = true
      second = new Gauntlet.Promise (resolve) ->
        resolvers[1] = resolve
      second.then ->
        resolves[1] = true
      setTimeout (-> resolvers[0] true), 100
      setTimeout (-> resolvers[1] true), 0
      Gauntlet.Promise.race([first, second]).then ->
        expect(resolves[1]).to.be.true
        expect(resolves[0]).to.be.undefined
        done()


    it 'should no-thenable promise resolve at first', (done) ->
      first = new Gauntlet.Promise (resolve, reject) ->
        resolve true
      second = new Gauntlet.Promise (resolve, reject) ->
        resolve false
      noop = 5
      Gauntlet.Promise.race([first, second, noop]).then (value) ->
        expect(value).to.equal 5
        done()


    it 'rejected as soon as a promise is rejected', (done) ->
      resolvers = []
      first = new Gauntlet.Promise (resolve, reject) ->
        resolvers[0] = { resolve, reject }
      second = new Gauntlet.Promise (resolve, reject) ->
        resolvers[1] = { resolve, reject }
      setTimeout (-> resolvers[0].reject {}), 0
      isRejectedFirst = undefined
      isCompletedSecond = undefined
      first.catch ->
        isRejectedFirst = true
      second
      .then ->
        isCompletedSecond = true
      .catch (reason) ->
        isCompletedSecond = true
        throw reason
      Gauntlet.Promise.race [first, second]
      .then ->
        expect(false).to.be.equal true, 'should not call me'
      .catch ->
        expect(isRejectedFirst).to.be.true
        expect(isCompletedSecond).to.be.undefined
        done()


    it 'resolves an empty array to forever pending promise', (done) ->
      foreverPendingPromise = Gauntlet.Promise.race []
      wasSettled = false
      foreverPendingPromise
      .then ->
        wasSettled = true
      .catch ->
        wasSettled = true
      setTimeout ->
        expect(wasSettled).to.be.false
        done()
      , 30


    it 'works with a mix of promises and thenables', (done) ->
      promise = new Gauntlet.Promise (resolve) ->
        setTimeout (-> resolve 1), 10
      syncThenable = then: (onResolved) -> onResolved 2
      Gauntlet.Promise.race([promise, syncThenable]).then (result) ->
        expect(result).to.be.equal 2
        done()


    it 'works with a mix of thenables and non-promises', (done) ->
      asyncThenable = then: (onResolved) ->
        setTimeout (-> onResolved 3), 0
      noop = 4
      Gauntlet.Promise.race([asyncThenable, noop]).then (result) ->
        expect(result).to.be.equal 4
        done()



  describe 'Gauntlet.Promise.resolve', ->
    it 'should remain pending until promised if pending', (done) ->
      resolver = undefined
      expected = 'the value'
      thenable = then: (resolve) -> resolver = resolve
      Gauntlet.Promise.resolve(thenable).then (value) ->
        expect(value).to.be.equal expected
        done()
      resolver expected


    it 'should resolve with the same value if resolved', (done) ->
      expected = 'the value'
      thenable = then: (resolve) -> resolve expected
      Gauntlet.Promise.resolve(thenable).then (value) ->
        expect(value).to.be.equal expected
        done()


    it 'should reject with the same reason if rejected', (done) ->
      expected =  new Error 'message'
      thenable = then: (resolve, reject) -> reject expected
      Gauntlet.Promise.resolve(thenable).then null, (reason) ->
        expect(reason).to.be.equal expected
        done()


    it 'should let then .then', (done) ->
      return done() if Object.defineProperty isnt 'function'
      thenable = {}
      accesses = 0
      Object.defineProperty thenable, 'then', get: ->
        accesses++
        throw new Error 'over access' if accessCount > 1
        return -> return
      expect(accesses).to.be.equal 0
      Gauntlet.Promise.resolve thenable
      expect(accesses).to.be.equal 1
      done()


    it 'should reject with same reason if retrieving reason', (done) ->
      expected = new Error 'message'
      thenable = {}
      Object.defineProperty thenable, 'then', get: ->
        throw expected
      Gauntlet.Promise.resolve(thenable).catch (reason) ->
        expect(reason).to.be.equal expected
        done()


    it 'should run Resolve if resolvePromise is called', (done) ->
      called = undefined
      resolver = undefined
      expected = 'success'
      thenable = then: (resolve, reject) ->
        called = this
        resolver = resolve
      Gauntlet.Promise.resolve(thenable).then (value) ->
        expect(called).to.be.equal thenable
        expect(expected).to.be.equal value
        done()
      resolver expected


    it 'should reject with same reason if rejectPromise is called', (done) ->
      called = undefined
      rejector = undefined
      expected = 'failure'
      thenable = then: (resolve, reject) ->
        called = this
        rejector = reject
      Gauntlet.Promise.resolve thenable
      .catch (reason) ->
        expect(expected).to.be.equal reason
        done()
      rejector expected


    it 'should precedence only first call if called multiple times', (done) ->
      resolver = undefined
      rejector = undefined
      expected = new Error 'message'
      calledResolved = 0
      calledRejected = 0
      thenable = then: (resolve, reject) ->
        calledThis = this
        resolver = resolve
        rejector = reject
      Gauntlet.Promise.resolve thenable
      .then ->
        calledResolved++
      .catch (reason) ->
        calledRejected++
        expect(calledResolved).to.be.equal 0
        expect(calledRejected).to.be.equal 1
        expect(reason).to.be.equal expected
      rejector expected
      rejector expected
      rejector 'foo'
      resolver 'bar'
      resolver 'baz'
      setTimeout ->
        expect(calledResolved).to.be.equal 0
        expect(calledRejected).to.be.equal 1
        done()
      , 30


    it 'should ignore if resolve or reject have been called', (done) ->
      expected = 'success'
      thenable = then: (resolve, reject) ->
        resolve expected
        throw expected
      Gauntlet.Promise.resolve(thenable).then (success) ->
        expect(success).to.be.equal expected
        done()


    it 'should reject as the reason, otherwise', (done) ->
      called = 0
      expected = new Error()
      Gauntlet.Promise.resolve(then: -> throw expected).catch (reason) ->
        called++
        expect(reason).to.be.equal expected
        done()
      expect(called).to.be.equal 0


    it 'should resolve if then is not a function', (done) ->
      called = 0
      thenable = then: 3
      Gauntlet.Promise.resolve(thenable).then (value) ->
        called++
        expect(value).to.be.equal thenable
        done()
      expect(called).to.be.equal 0


    it 'should resolve', (done) ->
      called = 0
      thenable = undefined
      Gauntlet.Promise.resolve(thenable).then (value) ->
        called++
        expect(value).to.be.equal thenable
        done()
      .catch (reason) ->
        expect(false).to.be.true
      expect(called).to.be.equal 0



  if module?.exports?
    describe 'using reduce to sum integers using promises', ->
      it 'should build the promise pipeline correctly without error', (done) ->
        (array or array = []).push i for i in [1..1000]
        result = array.reduce (promise, next) ->
          promise.then (current) ->
            Gauntlet.Promise.resolve current + next
        , Gauntlet.Promise.resolve 0
        result.then (value) ->
          expect(value).to.be.equal 1000 * (1000 + 1) / 2
          done()
