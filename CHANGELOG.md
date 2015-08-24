# 3.0.0

## Breaking Changes

- Signals now have *disposers*.
    - The return value from the setup function passed to the `Signal` or `ContinuousSignal` constructors is now significant. Since you shouldn't have been returning anything from these functions before, this is unlikely to break your code. However, if you're using a language like CoffeeScript which inserts implicit returns, you may need to update your code.
    - Signals can now enter into a "disposed" state. See [the readme](./README.md) for details on what that entails.
    - If you were holding onto signals that you were not subscribing to, you may need to add `use` calls to your code.
- Added two new functions to the mixin, `using` and `stopUsing`. Be aware that these could cause name collisions, so check anywhere that's using the mixin.
- Renamed `switch` to `if`.
- Changed the arguments to the `ContinuousSignal` constructor. Instead of:

    ```javascript
    new ContinuousSignal(initialValue, function(send) { /* ... */ });
    ```

    You must now write:

    ```javascript
    new ContinuousSignal(function(send) { send(initialValue); /* ... */ });
    ```

    Where `send` must be invoked once synchronously. This is consistent with the semantics of `derive` and with the `Signal` constructor.
- The return value from `subscribe` is just a function, instead of an object with a `remove` key.

    Update any code that looks like this:

    ```javascript
    subscription = signal.subscribe(/* ... */);
    subscription.remove();
    ```

    To something like this:

    ```javascript
    unsubscribe = signal.subscribe(/* ... */);
    unsubscribe();
    ```

## Additions

- Added the `spread` method to `Signal`.
- Added the `combine` method to `Signal`, as a shorthand for `Hearsay.combine`. `signal.combine(a, b)` is equivalent to `Hearsay.combine(signal, a, b)`
- Added the `merge` method to `Signal`, as a shorthand for `Hearsay.merge`. `signal.merge(a, b)` is equivalent to `Hearsay.merge(signal, a, b)`
- Added the `if` method to `Signal`, as a shorthand for `Hearsay.if`. `signal.if(a, b)` is equivalent to `Hearsay.if(signal, a, b)`.
- Added the `use` method to `Signal`.
- Added the `addDisposer` method to `Signal`.

# 2.1.0

- added `merge`

# 2.0.0

- added `subscribeChanges` method
- added `subscribeChanges` to the mixin (potentially breaking change)

# 1.0.0

- added `const`
- functions like `combine` are attached to `Hearsay`, not `Hearsay.Signal`
- added `Slot::update`

# 0.0.2

- I unpublished 0.0.1 from NPM to see what would happen, then tried to republish it but it turns out that's not allowed. So I bumped the version to 0.0.2. There weren't any actual changes.

# 0.0.1

- Initial commit
