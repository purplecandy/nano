import 'package:flutter/material.dart';

enum StoreTokenStatus { initialized, disposed, uninitialized, unknown }

/// Experimental Dependency Injection
/// Please use tools that you prefer
class StoreToken<T> {
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
  // StoreToken store<T>(T Function() callback) {
  //   final storeToken = register<T>(callback);
  //   create(storeToken);
  //   return storeToken;
  // }

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
      throw Exception("$token hasn't been initialized");
    else
      throw Exception("$token has already been disposed or it doesn't exist");
  }

  void uninitialize<T>(StoreToken token, StoreDisposer<T> dispose) {
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
      _uninitialized[token] = _reusable[token];
      _reusable.remove(token);
    }
  }

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
  final List<StoreToken> initialize, recreatable, uninitialize, dispose;
  final void Function() onInit, onDispose;
  StoreManager(
      {Key key,
      @required this.child,
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
  List<StoreToken> get initialize => widget.initialize;
  List<StoreToken> get uninitialize => widget.uninitialize;
  List<StoreToken> get dis => widget.dispose;
  List<StoreToken> get recreatable => widget.recreatable;

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
      Pool.instance.disposeStore(token, (store) => store.dispose());
    });
    uninitialize?.forEach((token) {
      Pool.instance.uninitialize(token, (store) => store.dispose());
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
