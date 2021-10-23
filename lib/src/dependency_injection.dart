import 'package:flutter/material.dart';
import 'package:nano/src/state_manager.dart';

enum StoreTokenStatus { initialized, disposed, uninitialized, unknown }

/// A unique token that represents a certain instance of the store
class StoreToken<T> {
  /// token value
  final String value;
  const StoreToken(this.value);

  ///Current status of the StoreToken
  StoreTokenStatus get status => Pool.instance.getTokenStatus(this);

  ///Store this token is attached to
  T get store => Pool.instance.obtain<T>(this);
  @override
  String toString() => "StoreToken: $value handling $T";
}

typedef StoreDisposer<T> = void Function(T store);

/// Pool is a depdency injection tool designed specifically for managing stores acros your apps.
/// It's recommended that you still use Provider/Consumer for passing around other dependencies or some other
/// serivce locator as it can be really hectic if you try to make it with Pool.
///
///
/// Pool from the name is a collection of `Stores`. Where all the stores are stores in a singleton but it doesn't
/// create singletons of the `Stores` itself. Every store is represented with a unique id called `StoreToken`, this token
/// is used to reference a partiuclar instance it has been registered with.
///
/// Pool tries to replicate the standard way of releasing resources when they have been used like the `Widget` but without any context.
///
/// The life cycle of a store is:
/// - register
/// - initialized
/// - disposed
///
/// Once your store has been disposed its `StoreToken`can no loger access or re-initialize the store. But there are certain exceptions,
/// sometimes a store's life cycle is short and it get's created and disposed again, but we can't create and reference
/// at compile time in such conditions, to overcome that a store can be initialized as recreateable, which can be
/// uninitialized which means release the resources but still being able to use the same token to create another instances.
///
/// In such a case the life cycle of a store becomes:
///  - register
///  - initialize
///  - uninitialize
///
/// To use it first you need to register an instance to get a token, this can be done by calling `Pool.instance.register()`
///
///
class Pool {
  int _tokens = 0;
  final Map<StoreToken, Function> _uninitialized = {};
  final Map<StoreToken, dynamic> _initialized = {};
  final Map<StoreToken, Null> _disposed = {};
  final Map<StoreToken, Function> _reusable = {};
  static final Pool instance = Pool._internal();

  factory Pool() {
    return instance;
  }

  Pool._internal();

  int _generateToken() => _tokens++;

  /// Returns a store token without instantiating
  StoreToken<T> register<T>(T Function() createInstance) {
    final randomToken = _generateToken().toString();
    final storeToken = StoreToken<T>(randomToken);
    _uninitialized[storeToken] = createInstance;
    return storeToken;
  }

  /// Initializes the Store
  ///
  /// set `recreate = true` to make it recreateable
  void create(StoreToken token, {bool recreate = false}) {
    if (_uninitialized.containsKey(token))
      try {
        _initialized[token] = _uninitialized[token]!.call();
        if (recreate) _reusable[token] = _uninitialized[token]!;
        _uninitialized.remove(token);
      } catch (e) {
        print("Exception occured when tried initializing the store");
        print("StoreToken: $token");
        rethrow;
      }
    else {
      if (_disposed.containsKey(token))
        throw Exception("Token expired. It has already been disposed");
      else
        throw Exception("Token doesn't exist.");
    }
  }

  /// Registers a token and initializes the store
  // StoreToken store<T>(T Function() callback) {
  //   final storeToken = register<T>(callback);
  //   create(storeToken);
  //   return storeToken;
  // }

  /// Disposes a store
  void disposeStore<T>(StoreToken token, StoreDisposer<T>? dispose) {
    if (_uninitialized.containsKey(token)) {
      throw Exception("Tried disposing an unitialized token");
    } else {
      if (_initialized.containsKey(token)) {
        final store = _initialized[token];
        try {
          dispose?.call(store);
        } catch (e, stack) {
          print("Execption occured when disposing the store");
          print(stack);
        }
        _initialized.remove(token);
        if (_reusable.containsKey(token)) _reusable.remove(token);
        _disposed[token] = null;
      } else {
        throw Exception(
            "Either the store is already disposed or it doesn't exist");
      }
    }
  }

  /// Returns the store instance from the token
  T obtain<T>(StoreToken token) {
    if (_initialized.containsKey(token))
      return _initialized[token];
    else if (_uninitialized.containsKey(token))
      throw Exception("$token hasn't been initialized");
    else
      throw Exception("$token has already been disposed or it doesn't exist");
  }

  /// Releases the resources of a recreateable store
  void uninitialize<T>(StoreToken token, StoreDisposer<T>? dispose) {
    if (_uninitialized.containsKey(token))
      throw Exception("$token hasn't been initialized");
    else if (_disposed.containsKey(token)) {
      throw Exception("$token has already been dispoed or it doesn't exist");
    } else {
      if (!_reusable.containsKey(token))
        throw Exception(
            "$token isn't re-createable. Only stores makred true as recreate can be unninitialize");

      final store = _initialized[token];
      try {
        dispose?.call(store);
      } catch (e, stack) {
        print("Execption occured when disposing the store");
        print(stack);
      }
      _initialized.remove(token);
      _uninitialized[token] = _reusable[token]!;
      _reusable.remove(token);
    }
  }

  /// Get current status of a `StoreToken`
  StoreTokenStatus getTokenStatus(StoreToken token) {
    if (_uninitialized.containsKey(token))
      return StoreTokenStatus.uninitialized;
    else if (_initialized.containsKey(token))
      return StoreTokenStatus.initialized;
    else if (_disposed.containsKey(token))
      return StoreTokenStatus.disposed;
    else
      return StoreTokenStatus.unknown;
  }
}

class StoreManager extends StatefulWidget {
  final Widget child;
  final List<StoreToken>? initialize, recreatable, uninitialize, dispose;
  final void Function()? onInit, onDispose;
  StoreManager(
      {Key? key,
      required this.child,
      this.onInit,
      this.onDispose,
      this.initialize,
      this.recreatable,
      this.uninitialize,
      this.dispose})
      : super(key: key);

  @override
  _StoreManagerState createState() => _StoreManagerState();
}

class _StoreManagerState extends State<StoreManager> {
  List<StoreToken>? get initialize => widget.initialize;
  List<StoreToken>? get uninitialize => widget.uninitialize;
  List<StoreToken>? get dis => widget.dispose;
  List<StoreToken>? get recreatable => widget.recreatable;

  @override
  void initState() {
    super.initState();
    widget.onInit?.call();
    initialize?.forEach((token) {
      Pool.instance.create(token);
    });
    recreatable?.forEach((token) {
      Pool.instance.create(token, recreate: true);
    });
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    dis?.forEach((token) {
      Pool.instance.disposeStore<Store>(token, (store) => store.dispose());
    });
    uninitialize?.forEach((token) {
      Pool.instance.uninitialize<Store>(token, (store) => store.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
