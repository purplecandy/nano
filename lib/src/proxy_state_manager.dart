import 'package:meta/meta.dart';
import 'dart:async';

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

  @mustCallSuper
  void close() {
    _subscription.cancel();
  }
}
