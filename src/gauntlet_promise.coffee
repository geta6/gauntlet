'use strict'


class Promise

  PENDING = undefined
  SEALED = 0
  RESOLVED = 1
  REJECTED = 2

  async = do ->
    queue = []

    flush = ->
      tuple[0] tuple[1] while tuple = queue.shift()

    schedule = do ->
      if typeof window is 'undefined'
        return -> process.nextTick flush
      return -> setTimeout flush, 0

    return (callback, argument) ->
      length = queue.push [callback, argument]
      schedule()
      return

  subscribe = do ->
    return (parent, child, onResolved, onRejected) ->
      {length} = parent.__subscribers
      parent.__subscribers[length] = child
      parent.__subscribers[length + RESOLVED] = onResolved
      parent.__subscribers[length + REJECTED] = onRejected
      return

  [trigger, invoker] = do ->
    handle = (promise, value) ->
      next = undefined
      resolved = undefined
      try
        if promise is value
          throw new TypeError 'Promise callback cannot return itself'
        type = typeof value
        if (type is 'function') or ((type is 'object') and (value isnt null))
          next = value.then
          if typeof next is 'function'
            ok = (val) ->
              return true if resolved
              resolved = true
              if value isnt val
                resolve promise, val
              else
                fulfill promise, val
            ng = (val) ->
              return true if resolved
              resolved = true
              reject promise, val
            next.call value, ok, ng
            return true
      catch reason
        return true if resolved
        reject promise, reason
        return true
      return false

    resolve = (promise, value) ->
      if promise is value
        return fulfill promise, value
      else if not handle promise, value
        return fulfill promise, value

    fulfill = (promise, value) ->
      return if promise.__state isnt PENDING
      promise.__state = SEALED
      promise.__detail = value
      async publishWithResolved, promise

    reject = (promise, reason) ->
      return if promise.__state isnt PENDING
      promise.__state = SEALED
      promise.__detail = reason
      async publishWithRejected, promise

    publishWithResolved = (promise) ->
      publish promise, promise.__state = RESOLVED

    publishWithRejected = (promise) ->
      publish promise, promise.__state = REJECTED

    publish = (promise, settled) ->
      detail = promise.__detail
      {length} = subscribers = promise.__subscribers
      for i in [0...(subscribers.length / 3)]
        child = subscribers[i * 3]
        trigger settled, child, subscribers[i * 3 + settled], detail
      subscribers = promise.__subscribers = null
      return

    trigger = (settled, promise, callback, detail) ->
      value = undefined
      reason = undefined
      success = false
      failure = false
      if hasCallback = typeof callback is 'function'
        try
          value = callback detail
          success = true
        catch error
          reason = error
          failure = true
      else
        value = detail
        success = true
      return if handle promise, value
      return resolve promise, value if success and hasCallback
      return reject promise, reason if failure
      return resolve promise, value if settled is RESOLVED
      return reject promise, value if settled is REJECTED

    invoker = (resolver, promise) ->
      promiseResolver = (value) -> resolve promise, value
      promiseRejector = (reason) -> reject promise, reason
      try
        resolver promiseResolver, promiseRejector
      catch reason
        promiseRejector reason

     return [trigger, invoker]

  @resolve = (value) ->
    if value? and (typeof value is 'object') and (value.constructor is this)
      return value
    return new this (resolve) ->
      return resolve value

  @reject = (reason) ->
    new Promise (resolve, reject) ->
      return reject reason

  @all = (promises) ->
    unless (Object::toString.call promises) is '[object Array]'
      throw new TypeError 'An array as the first argument required.'

    return new Promise (resolve, reject) ->
      results = []
      {length} = promises
      return resolve [] if length is 0
      resolveAll = (index, value) ->
        results[index] = value
        resolve results if --length is 0
      resolveFactory = (index) ->
        return (value) ->
          resolveAll index, value
      for promise, i in promises
        if promise and typeof promise.then is 'function'
          promise.then (resolveFactory i), reject
        else
          resolveAll i, promise
      return

  @race = (promises) ->
    unless (Object::toString.call promises) is '[object Array]'
      throw new TypeError 'An array as the first argument required.'

    return new Promise (resolve, reject) ->
      results = []
      for promise in promises
        if promise and typeof promise.then is 'function'
          promise.then resolve, reject
        else
          resolve promise
      return

  __state: PENDING
  __detail: undefined
  __subscribers: undefined

  constructor: (resolver) ->
    if typeof resolver isnt 'function'
      throw new TypeError 'A function as the first argument required.'
    unless this instanceof Promise
      throw new TypeError 'Cannot be called as a function.'
    @__subscribers = []
    invoker resolver, this

  then: (onResolved, onRejected) ->
    promise = new @constructor -> return
    if @__state
      callbacks = arguments
      async => trigger @__state, promise, callbacks[@__state - 1], @__detail
    else
      subscribe this, promise, onResolved, onRejected
    return promise

  catch: (onRejected) ->
    return @then null, onRejected


module.exports = Promise

