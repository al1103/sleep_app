import 'dart:async';

/**
 * How to use app_debounce
 * ! Use the debounce by calling debounce
 * AppDebounce.debounce(
      'my-debounce',                 // <-- An ID for this particular debounce (tag)
      Duration(milliseconds: 500),    // <-- The debounce duration
      () => myMethod()                // <-- The target method
    );
 * ! Cancel the debounce
 * AppDebounce.cancel([tag]);
 * AppDebounce.cancelAll();
 * ! Count active throttles
 * ${AppDebounce.count()}
 * ! Fire a debounce target function manually
 * Fire the target function of a debounce before the timer executes
 * This will execute the debounce target function, but the debounce timer will keep running unless you also call cancel()
 * AppDebounce.fire([tag]);
 */

/// A void callback, i.e. (){}, so we don't need to import e.g. `dart.ui`
/// just for the VoidCallback type definition.
typedef AppDebounceCallback = void Function();

class _AppDebounceOperation {
  _AppDebounceOperation(this.callback, this.timer);
  AppDebounceCallback callback;
  Timer timer;
}

/// A static class for handling method call debouncing.
class AppDebounce {
  static final Map<String, _AppDebounceOperation> _operations = {};

  /// Will delay the execution of [onExec] with the given [duration]. If another call to
  /// debounce() with the same [tag] is called within this duration, the first call will be
  /// cancelled and the debounce will start waiting for another [duration] before executing
  /// [onExec].
  ///
  /// [tag] is any arbitrary String, and is used to identify this particular debounce
  /// operation in subsequent calls to [debounce()] or [cancel()].
  ///
  /// If [duration] is `Duration.zero`, [onExec] will be executed immediately,
  static void debounce(
      String tag, Duration duration, AppDebounceCallback onExec,) {
    if (duration == Duration.zero) {
      _operations[tag]?.timer.cancel();
      _operations.remove(tag);
      onExec();
    } else {
      _operations[tag]?.timer.cancel();

      _operations[tag] = _AppDebounceOperation(
          onExec,
          Timer(duration, () {
            _operations[tag]?.timer.cancel();
            _operations.remove(tag);

            onExec();
          }),);
    }
  }

  /// Fires the callback associated with [tag] immediately. This does not cancel the debounce timer,
  /// so if you want to invoke the callback and cancel the debounce timer, you must first call
  /// `fire(tag)` and then `cancel(tag)`.
  static void fire(String tag) {
    _operations[tag]?.callback();
  }

  /// Cancels any active debounce operation with the given [tag].
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// Cancels all active debounce.
  static void cancelAll() {
    for (final operation in _operations.values) {
      operation.timer.cancel();
    }
    _operations.clear();
  }

  /// Returns the number of active debounce (debounce that haven't yet called their
  /// [onExec] methods).
  static int count() {
    return _operations.length;
  }
}