import 'package:flutter_test/flutter_test.dart';
import 'package:nano/nano.dart';

void main() {
  /// This test verifis that ModifiedSubject retains the cached value even when an error is emitted
  test("ModifiedSubject Cache Value Test", () {
    // ignore: close_sinks
    final counter = ModifiedBehaviorSubject<int>.seeded(0);
    expect(counter.value, counter.cachedValue);
    counter.add(1);
    expect(counter.value, counter.cachedValue);
    counter.addError(Exception());
    expect(counter.value, isNot(counter.cachedValue));
    expect(counter.cachedValue, 1);
    counter.add(2);
    expect(counter.value, counter.cachedValue);
  });
}
