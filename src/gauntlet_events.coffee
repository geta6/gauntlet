'use strict'


class Events

  constructor: ->
    @__events = {}

  listeners: (event) ->
    Array.apply this, @__events[event] or []

  trigger: (event, a1, a2, a3, a4, a5) ->
    return false if (not @__events) or (not @__events[event])
    callbacks = @__events[event]
    callback = callbacks[0]
    callbackLength = callbacks.length
    argument = []
    argumentLength = arguments.length
    if callbackLength is 1
      @off event, callback if callback.__one
      switch argumentLength
        when 1 then callback.call (callback.__ctx or this)
        when 2 then callback.call (callback.__ctx or this), a1
        when 3 then callback.call (callback.__ctx or this), a1, a2
        when 4 then callback.call (callback.__ctx or this), a1, a2, a3
        when 5 then callback.call (callback.__ctx or this), a1, a2, a3, a4
        when 6 then callback.call (callback.__ctx or this), a1, a2, a3, a4, a5
        else
          argument[i - 1] = arguments[i] for i in [1...argumentLength]
          callback.apply (callback.__ctx or this), argument
    else
      argument[i - 1] = arguments[i] for i in [1...argumentLength]
      for callback in callbacks
        @off event, callback if callback.__one
        callback.apply (callback.__ctx or this), argument
    return true

  on: (event, callback, context) ->
    @__events = {} unless @__events
    @__events[event] = [] unless @__events[event]
    callback.__ctx = context
    @__events[event].push callback
    return this

  once: (event, callback, context) ->
    callback.__one = true
    return @on event, callback, context

  off: (event, callback, context) ->
    return this unless @__events
    if callback
      return this unless @__events[event]
      events = []
      for __callback in @__events[event] when __callback
        if __callback isnt callback or __callback.__ctx isnt context
          events.push __callback
      @__events[event] = if events.length then events else null
    else
      if event then @__events[event] = null else @__events = {}
    return this


module.exports = Events

