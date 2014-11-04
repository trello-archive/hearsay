# Hearsay.js

A library for observing keys of objects. Don't use it. The API is in severe flux. It's not even published yet. You can't use it.

# Concepts

## Signals

A signal is a stream of events. Signals never complete. There are two types of signals, continuous and discrete.

### Continuous Signals

Continuous signals have a "current value," and when you subscribe to a continuous signal the callback is triggered immediately.

Continuous signals have an extra method, `.get()`, which returns the current value of the signal.

Only continuous signals can be sampled. You can promote discrete signals into continuous signals with `.cache`. This isn't actually implemented yet and the name might change.

Example: value of a `textarea`.

### Discrete Signals

Discrete signals do not send events immediately, but only when a value becomes available. You can't discrete continuous signals with `.get()` or `.sample()`.

Example: click events.

You can convert a discrete signal into a continuous signal with `.cache` or `.remember` or something like that.

## Slots

A slot is a container for a value. You can think of it as a mutable continuous signal -- a signal with a current value that can be changed by invoking the `.set` method.

## Observations

An observation is an object with one method: `remove`. When you watch something, it returns an observation that you can use to stop watching that thing.

The mixin form of the API makes this easier if you want to do all of your cleanup in one place.

# API

Hearsay exports an object that looks like this:

    watch: (Object, (String | Array), Function, Object?) -> Observation
    mixin:
      watch: (Object, (String | Array), Function) -> Observation
      unwatch: () -> ()
    Slot: "Class"

`Function` refers to a function that takes one argument and returns nothing. The return value is ignored, so if you do return something it won't yell at you or anything. But you don't need to. Doesn't make sense.

## `Slot`

    new Slot: (Any) -> Slot
    slot.get: () -> Any
    slot.set: (Any) -> Any
    slot.subscribe: (Function, Object?) -> Observation

Example usage:

    name = new Slot "Emily"
    console.log name.get()
    >> Emily

    name.set "James"
    console.log name.get()
    >> James

    observation = name.subscribe (val) ->
      console.log "Name is #{val}"
    >> Name is James

    name.set "Mary"
    >> Name is Mary
    console.log name.get()
    >> Mary

    observation.remove()
    name.set "Penelope"
    console.log name.get()
    >> Penelope

The second argument to `subscribe` is the context with which the `callback` will be invoked.

## `watch`

`watch` is used for nested observation.

`watch` will invoke its callback as soon as it's added. Use a skip combinator if you don't want this behavior.

Don't forget to `.remove()` the observation returned by `watch`.

You can pass `watch` either a string of dot-separated keypaths or an array of strings (in case your keys have dots in them).

The last argument is the context with which the callback will be invoked.

## Mixin

A potentially nicer way to use Slots is as a mixin on your objects, as it can make cleanup easier.

This will introduce the `watch` and `unwatch` methods, and a variable used to maintain state called `_hearsay_observations`.

## `watch`

Usage:

    this.subscribe(target, 'foo.bar.baz', callback)

Adds a nested watcher. `callback` is always invoked with `this` as the context.

If `target` is omitted, `this` is assumed. Thus the following two lines are equivalent:

    this.subscribe('foo.bar.baz', callback)
    this.subscribe(this, 'foo.bar.baz', callback)

## `unwatch`

Removes all observations created via `this.subscribe`.

For more fine-grained watch-removal, hold onto the return value from `this.subscribe` and invoke its `remove` method.

# Why aren't you just using signal combinators

Shhhhh.
