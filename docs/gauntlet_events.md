# Gauntlet.Events

faster eventemitter.

## Example

### Listening events

```coffee
{Events} = require 'gauntlet'

event = new Events()
event.on 'test', (value) ->
  console.log value

event.trigger 'test' # will log 'test'
event.trigger 'test' # will log 'test'

event.off 'test'

event.trigger 'test' # nothing will happen
```

### Listening once

```coffee
{Events} = require 'gauntlet'

event = new Events()
event.once 'test', (value) ->
  console.log value

event.trigger 'test' # will log 'test'
event.trigger 'test' # nothing will happen
```

### Show all listeners

```coffee
{Events} = require 'gauntlet'

event = new Events()
event.on 'test', (value) ->
  console.log value

event.listeners()
```
