import 'package:flutter_test/flutter_test.dart';
import 'package:nano/nano.dart';
import 'mock_data/counter.dart';

void addListener(CounterStore counter, int dcount, int ecount) {
  int _dcount = 0;
  int _ecount = 0;
  counter.stream.listen((e) {
    // expectAsync1(verifyData, count: dcount);
    verifyData(e);
    _dcount++;
    if (_dcount > dcount) throw Exception("Data count increased");
  }, onError: (e) {
    verifyError(e);
    _ecount++;
    if (_ecount > ecount) throw Exception("Error called more times");
  }, onDone: () {
    if (_ecount != ecount)
      throw Exception("Invalid Error count wasn't called enough times");
    if (_dcount != dcount)
      throw Exception("Invalid Data count wasn't called enough times");
  });
}

void verifyError(StateSnapshot<int> event) {
  expect(event.hasError, true);
  expect(event.hasData, false);
  expect(event.waiting, false);
  expect(event.data, null);
  expect(event.error, "Invalid action");
}

void verifyData(StateSnapshot<int> event) {
  expect(event.hasError, false);
  expect(event.hasData, true);
  expect(event.waiting, false);
  expect(event.error, null);
  expect(event.data, count);
}

int count = 0;

main() {
  /// Validating interchaning data and error events
  /// Stream sequence is `[0,1,"Invalid action",2,"Invalid action"]`
  /// Listeners will receive this sequce as Data and Error
  /// depending upon the moment they have been attached
  /// Goal of this test it to verify that listeners only get the right amount data and error
  group("Store streams test", () {
    test("Listeners test", () async {
      final counter = CounterStore();
      counter.stream
          .listen((event) => print("Data"), onError: (e) => print("Error"));
      addListener(counter, 3, 2);
      await incrementRef(payload: counter, onDone: () => count++).run();
      errortRef(payload: counter).run();

      /// Error hasn't been completed so it will still receive current state which is a Data
      addListener(counter, 2, 2);

      await Future.delayed(Duration(milliseconds: 100));
      addListener(counter, 1, 2);
      var action = incrementRef(payload: counter, onDone: () => count++)..run();
      errortRef(payload: counter, waitFor: [action.id]).run();
      await Future.delayed(Duration(
          milliseconds: 100)); //waiting for the above action to complete
      counter.dispose();
    });
  });
}
