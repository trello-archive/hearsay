[![Build Status](https://travis-ci.org/trello/hearsay.svg)](https://travis-ci.org/trello/hearsay)

# Hearsay.js

Hearsay is not stable enough for real world use. The implementation is incomplete, the documentation is laughable, and interface is still in flux.

That said, it uses semver, so feel free to depend on it.

# Concepts

## Signals

A signal is a stream of events. Signals never complete. There are two types of signals, continuous and discrete.

### Continuous Signals

Continuous signals have a "current value," and when you subscribe to a continuous signal the callback is triggered immediately.

Continuous signals have an extra method, `.get()`, which returns the current value of the signal.

Only continuous signals can be sampled. You can promote discrete signals into continuous signals with `.cache`. This isn't actually implemented yet and the name might change.

Example: value of a `textarea`.

### Discrete Signals

Discrete signals do not send events immediately, but only when a value becomes available. You can't invoke `.get()` or `.sample()` on discrete signals.

Example: click events.

You can convert a discrete signal into a continuous signal with `.cache` or `.remember` or something like that.

## Slots

A slot is a container for a value. You can think of it as a mutable continuous signal -- a signal with a current value that can be changed by invoking the `.set` method.

## Subscriptions

When you subscribe to a signal, that signal will return a function that you can invoke to `unsubscribe` from it.

In previous versions of Hearsay, `subscribe` used to return an object with one method, `remove`. Now it just returns the `remove` method as a function.

The mixin form of the API makes this easier if you want to do all of your cleanup in one place.

## Disposers

An important part of signal maintenance is cleaning up after yourself. If the creation of a signal involves a side effect that needs to be undone, you can return a disposer from the setup block.

To see when this can be useful, let's consider an example: say we're writing an application that uses [Backbone](http://backbonejs.org/). We would like one of our models to expose an attribute as a signal:

```javascript
var Person = Backbone.Model.extend({
  getName: function() {
    var self = this;
    return new ContinuousSignal(self.get('name'), function(send) {
      self.on('change:name', function(_, name) {
        send(name);
      });
    });
  }
});
```

While this works, it has a big problem: there is no corresponding `off` call. Even if you're no longer subscribing to this signal, it will continue to observe changes to the `name` attribute and forever send events into the void.

To solve this, we return a "disposer" from the signal. A disposer is a function that takes no arguments and performs the necessary work to clean up the signal when we're done with it (details on precisely what that means below).

In the Backbone case, our disposer would look like this:

```javascript
var Person = Backbone.Model.extend({
  getName: function() {
    var self = this;
    return new ContinuousSignal(self.get('name'), function(send) {
      var listener = function(_, name) {
        send(name);
      };
      self.on('change:name', listener);
      return function() {
        self.off('change:name', listener);
      };
    });
  }
});
```

### When is the disposer invoked?

A signal maintains a (private) use count. The count starts at `0`.

Every time you call `signal.use` on a signal, it increments its count.

Every time you invoke the return value of `signal.use`, it decrements its count.

Whenever a signal's use count is `0`, it schedules itself for disposal. All newly created signals are scheduled for disposal, because they start with a use count of `0`.

If a signal that is scheduled for disposal still has a use count of `0` when the scheduler runs, it disposes of itself by invoking the disposer it was created with.

By default, the scheduler is `setTimeout`. You can use `Hearsay.setScheduler(fn)` to change this (for example, to use `setImmediate` in Node, or to use a more deterministic scheduler for testing).

Yes, this is basically an ad-hoc implementation of reference counting. Yes, this is all ripped off from [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)'s resource management.

### I need to see an example of that.

Fair enough. Let's start simple:

```javascript
var signal = new Signal(/* ... */); // use count = 0
stopUsing1 = signal.use();          // use count = 1
stopUsing2 = signal.use();          // use count = 2
stopUsing1();                       // use count = 1
stopUsing3 = signal.use();          // use count = 2
stopUsing3();                       // use count = 1
stopUsing2();                       // use count = 0
```

At this point the signal is scheduled for disposal, so if nothing else `use`s it by the next tick of the run loop, it will be disposed.

Now let's look at what happens here:

```javascript
var signal1 = new Signal(/* ... */);
var signal2 = signal1.map(/* ... */);
```

After the first statement is executed, `signal1` has a use count of `0`. After the second statement is executed, `signal1` has a use count of `1` (`signal2` is using it), and `signal2` has a use count of `0`, thus it is scheduled for disposal. If we leave things be, and don't interact with these signals any more, the following things will happen:

- `signal2` will be disposed on the next tick of the run loop.
- This will decrement `signal1`'s use count, and schedule it for disposal as well (since `signal2` is no longer using it).
- Since we're already running a disposal operation, `signal1` will be disposed of as well -- it won't wait for the next tick, since it was triggered for disposal from another signal's disposer.

### When should you invoke `use`?

You usually shouldn't need to invoke `use` by hand, because:

- `subscribe` invokes `use` for you, so usually you will implicitly "use" signals just by subscribing to them.
- Deriving new signals using any of the built-in combinators will
`use` the underlying signals.

But there are cases where you might have to invoke `use` directly:

- If you're writing a combinator that doesn't directly subscribe to its inputs, you will need to explicitly call `use` on the inputs you don't subscribe to. For example, see the implementation of [the `switch` combinator](./src/functions/switch.coffee).
- If you're maintaining a reference to a signal that you're going to subscribe to later.

The latter case is probably the only time you'll need to invoke `use` directly. Let's look at an example: say we're writing a Backbone app again, and we have some "view" code:

```javascript
var PersonView = Backbone.View.extend({
  initialize: function() {
    this.nameSignal = this.model.getName();
  },
  render: function() {
    var self = this;
    self.nameSignal.subscribe(function(name) {
      self.el.innerText = name;
    });
  }
});
```

This code *might* work, but it might not. If `render` is invoked synchronously after `initialize`, then it's fine. But if `render` is invoked any *later* than that -- say, after a timeout or a network request -- then `nameSignal` will have already been disposed, and the code will fail with an error.

How can you fix that? Add an explicit `use` call that you invoke synchronously:

```javascript
var PersonView = Backbone.View.extend({
  initialize: function() {
    this.nameSignal = this.model.getName();
    this._unuseNameSignal = this.nameSignal.use();
  },
  remove: function() {
    this._unuseNameSignal();
    Backbone.View.prototype.remove.apply(this, arguments);
  },
  render: function() {
    var self = this;
    self.nameSignal.subscribe(function(name) {
      self.el.innerText = name;
    });
  }
});
```

Always remember to hold on to the return value from `use` so that you can "unuse" it later.

If you're using the Hearsay mixin, you can use the `using` helper to automatically clean up multiple signals:

```javascript
var PersonView = Backbone.View.extend({
  initialize: function() {
    this.nameSignal = this.using(this.model.getName());
    this.ageSignal = this.using(this.model.getAge());
  },
  remove: function() {
    this.stopUsing();
    Backbone.View.prototype.remove.apply(this, arguments);
  }
  // render elided
});
_.extend(PersonView.prototype, Hearsay.mixin);
```

### What happens after a signal is disposed?

After a signal has been disposed, it is an error to interact with the signal. This means you can't call any methods on it, you can't pass it as an argument to functions like `Hearsay.merge`, etc.

More precisely, it becomes an error to invoke `use` or `addDisposer` on a disposed signal or to invoke the send function passed into its initialization callback.

The former point means that you basically can't interact with a signal that has been disposed, since all combinators will invoke `use` either directly or indirectly.

That latter point is more subtle, and very important. It means that if you're writing a custom signal directly with the constructors, you need to make sure that the disposer you return will actually stop sending any new values. For example, the following code is broken, and will throw an exception once the returned signal is disposed:

```javascript
var intervalSignal = function(duration) {
  return new Signal(function(send) {
    setInterval(send, duration);
  });
};
```

You need to write something like this instead:

```javascript
var intervalSignal = function(duration) {
  return new Signal(function(send) {
    var id = setInterval(send, duration);
    return function() {
      clearInterval(id);
    };
  });
};
```

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

    unsubscribe = name.subscribe (val) ->
      console.log "Name is #{val}"
    >> Name is James

    name.set "Mary"
    >> Name is Mary
    console.log name.get()
    >> Mary

    unsubscribe()
    name.set "Penelope"
    console.log name.get()
    >> Penelope

The second argument to `subscribe` is the context with which the `callback` will be invoked.

## `watch`

`watch` is used for nested observation.

`watch` will invoke its callback as soon as it's added. Use a skip combinator if you don't want this behavior.

Don't forget to invoke the `unsubscribe` function returned by `watch`.

You can pass `watch` either a string of dot-separated keypaths or an array of strings (in case your keys have dots in them).

The last argument is the context with which the callback will be invoked.

## Mixin

A potentially nicer way to use `Slot`s is as a mixin on your objects, as it can make cleanup easier.

This will introduce the `subscribe`, `subscribeChanges`, `watch`, and `unsubscribe` methods. It will also attach the key `_hearsay_observations` that is used to track private state.

## `watch`

Usage:

    this.watch(target, 'foo.bar.baz', callback)

Adds a nested watcher. `callback` is always invoked with `this` as the context.

If `target` is omitted, `this` is assumed. Thus the following two lines are equivalent:

    this.watch('foo.bar.baz', callback)
    this.watch(this, 'foo.bar.baz', callback)

## `unsubscribe`

Removes all observations created via `this.subscribe`, `this.subscribeChanges`, or `this.watch`.

For more fine-grained cleanup, hold onto the return value from `this.subscribe`, `this.subscribeChanges`, or `this.watch` and invoke its `remove` method.

## `using`
## `stopUsing`
