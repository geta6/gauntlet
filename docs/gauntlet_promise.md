# Gauntlet.Promise

A polyfill for ES6-style Promises, implementation of [Promises/A+](http://promises-aplus.github.io/promises-spec/).

## Example

### Plain Success

```coffee
{Promise} = require 'gauntlet'

new Promise (resolve, reject) ->
  resolve foo: 'bar'
.then (value) ->
  console.log value # will be `{ foo: 'bar' }`
.catch (reason) ->
  console.log reason # never
console.log 'test'
```

`'test'` will shown first, promise callback always call asynchronously.

### Plain Failure

```coffee
{Promise} = require 'gauntlet'

new Promise (resolve, reject) ->
  reject new Error 'do not call me'
.then (value) ->
  console.log value # never
.catch (reason) ->
  console.log reason # will be `[Error: do not call me]`
console.log 'test'
```

### With Redis

### Plain

```coffee
redis = require 'redis'
client = redis.createClient()

{Promise} = require 'gauntlet'

key = 'test'
val = testKey: 'testVal'

promise = new Promise (resolve, reject) ->
  client.multi()
  .hmset key, val
  .hgetall key
  .exec (err, res) ->
    client.quit()
    return reject err if err
    resolve res[1]

promise.then (value) ->
  console.log value # will be `{ testKey: 'testVal' }` from `exec` callback

promise.catch (reason) ->
  console.log reason # will be `Error` from `exec` callback
```

### Nested

```coffee
redis = require 'redis'
client = redis.createClient()

{Promise} = require 'gauntlet'

key = 'test'
val = testKey: 'testVal'

promise = new Promise (resolve, reject) ->
  client.multi()
  .hmset key, val
  .hgetall key
  .exec (err, res) ->
    return reject err if err
    client.del key, (err, res) ->
      client.quit()
      return reject err if err
      resolve res

promise.then (value) ->
  console.log value # will be `OK` from `del` callback

promise.catch (reason) ->
  console.log reason # will be `Error` from `exec` or `del` callback
```

### Chain


```coffee
redis = require 'redis'
client = redis.createClient()

{Promise} = require 'gauntlet'

key = 'test'
val = testKey: 'testVal'

promise = new Promise (resolve, reject) ->
  client.multi()
  .hmset key, val
  .hgetall key
  .exec (err, res) ->
    client.quit()
    return reject err if err
    resolve res[1]

promise
.then (value) ->
  console.log value # will be `{ testKey: 'testVal' }` from `exec` callback
  return value.testKey
.then (value) ->
  console.log value # wiil be `'testVal'`

promise.catch (reason) ->
  console.log reason # will be `Error` from `exec` callback
```
