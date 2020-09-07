import 'package:flutter/material.dart';

/// Experimental Dependency Injection
/// Please use tools that you prefer
class StoreToken {
  final String value;
  const StoreToken(this.value);

  @override
  String toString() => value;
}

typedef StoreDisposer<T> = void Function(T store);

class Pool {
  final Map<StoreToken, Function> _uninitialized = {};
  final Map<StoreToken, dynamic> _initialized = {};
  final Map<StoreToken, Null> _disposed = {};
  final Map<StoreToken, Function> _reusable = {};
  static final Pool _pool = Pool._internal();

  factory Pool() {
    return _pool;
  }

  Pool._internal();

  /// Returns a store token without instantiating
  StoreToken register<T>(T Function() createInstance) {
    final randomToken = DateTime.now().millisecondsSinceEpoch.toString();
    final storeToken = StoreToken(randomToken);
    _uninitialized[storeToken] = createInstance;
    return storeToken;
  }

  /// Initializes the Store
  void create(StoreToken token, {bool recreate = false}) {
    if (_uninitialized.containsKey(token))
      try {
        _initialized[token] = _uninitialized[token].call();
        if (recreate) _reusable[token] = _uninitialized[token];
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
  StoreToken store<T>(T Function() callback) {
    final storeToken = register<T>(callback);
    create(storeToken);
    return storeToken;
  }

  void disposeStore<T>(StoreToken token, StoreDisposer<T> dispose) {
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

  T obtain<T>(StoreToken token) {
    if (_initialized.containsKey(token))
      return _initialized[token];
    else if (_uninitialized.containsKey(token))
      throw Exception("Store $token hasb't been initialized");
    else
      throw Exception(
          "Store $token has already been disposed or it doesn't exist");
  }

  void uninitialize<T>(StoreToken token, StoreDisposer<T> dispose) {
    if (_uninitialized.containsKey(token))
      throw Exception("Store $T $token hasn't been initialized");
    else if (_disposed.containsKey(token)) {
      throw Exception(
          "Store $token has already been dispoed or it doesn't exist");
    } else {
      if (!_reusable.containsKey(token))
        throw Exception(
            "Store isn't re-createable. Only stores makred true as recreate can be unninitialize");

      final store = _initialized[token];
      try {
        dispose?.call(store);
      } catch (e, stack) {
        print("Execption occured when disposing the store");
        print(stack);
      }
      _initialized.remove(token);
      _uninitialized[token] = _reusable[token];
      _reusable.remove(token);
    }
  }
}

class InitializeStore<T> extends StatefulWidget {
  final StoreToken storeToken;
  final StoreDisposer<T> dispose;
  final Widget Function(T store) child;
  InitializeStore({Key key, this.storeToken, this.dispose, this.child})
      : super(key: key);

  @override
  _InitializeStoreState<T> createState() => _InitializeStoreState<T>();
}

class _InitializeStoreState<T> extends State<InitializeStore<T>> {
  T store;
  @override
  void initState() {
    super.initState();
    Pool().create(widget.storeToken);
    store = Pool().obtain<T>(widget.storeToken);
  }

  @override
  void dispose() {
    Pool().disposeStore<T>(widget.storeToken, widget.dispose);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child(store);
  }
}
