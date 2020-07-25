import 'package:meta/meta.dart';
import 'dart:async';

import 'package:nano/nano.dart';

abstract class ProxyStream<T> {
  StreamSubscription<T> _subscription;

  void mapper({T event, bool isError = false, Object error});

  void init(Stream<T> stream) {
    _subscription = stream.listen(
      (event) {
        mapper(event: event);
      },
      onError: (error) => mapper(isError: true, error: error),
    );
  }

  bool _verifyProxyAction(ActionId id) {
    try {
      return Dispatcher.instance.verify(id);
    } catch (e) {
      print(e);
      return false;
    }
  }

  void proxyReducer(Store store, dynamic mutation) {
    if (_verifyProxyAction(store.lastAction))
      store.reducer(mutation);
    else
      print("Skipping Mutation: Unauthorised Action");
    Dispatcher.instance.completeProxyAction(store.lastAction);
  }

  @mustCallSuper
  void close() {
    _subscription.cancel();
  }
}
