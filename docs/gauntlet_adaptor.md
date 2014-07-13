# Gauntlet.Adaptor

model backend.

`Adaptor` has REST API defaults.

prototype methods return `Gauntlet.Promise` instance.

instance extends `Gauntlet.Events`.

## Example

server spec in `test/fixture/app.coffee`.

initially stored resource is `{'user:1': {id: 1, name: 'test'}}`.

### Check exists

send `HEAD` request to check resource exists or not.

should reject if resource not exists.

```coffee
{Adaptor} = require 'gauntlet'

Adaptor.exists 'user:1'
.then (value) ->
  console.log value.status # 200 / 404
  console.log value.body # null
.catch (reason) ->
  console.error reason # maybe connection error
```

### Get

send `GET` request to get resource.

should reject if resource not exists.

```coffee
{Adaptor} = require 'gauntlet'

Adaptor.select 'user:1'
.then (value) ->
  console.log value.status # 200 / 404
  console.log value.body # { id: 1, name: 'test' } / null
.catch (reason) ->
  console.error reason # maybe connection error
```

### Create

send `POST` request to create resource.

should reject if resource exists.

```coffee
{Adaptor} = require 'gauntlet'

Adaptor.insert 'user:2', { id: 2, name: 'test2' }
.then (value) ->
  console.log value.status # 201 / 403
  console.log value.body # { id: 2, name: 'test2' } / null
.catch (reason) ->
  console.error reason # maybe connection error
```

### Delete

send `DELETE` request to delete resource.

should reject if resource not exists.

```coffee
{Adaptor} = require 'gauntlet'

Adaptor.delete 'user:2'
.then (value) ->
  console.log value.status # 204 / 404
  console.log value.body # null
.catch (reason) ->
  console.error reason # maybe connection error
```

### Update

send `PUT` request to partially update resource.

should reject if resource not exists.

```coffee
{Adaptor} = require 'gauntlet'

Adaptor.update 'user:1', { name: 'test1', mail: 'test@example.com' }
.then (value) ->
  console.log value.status # 200 / 404
  console.log value.body # { id: 1, name: 'test1', mail: 'test@example.com' } / null
.catch (reason) ->
  console.error reason # maybe connection error
```
