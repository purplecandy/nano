import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:nano/nano.dart';

void spawn(message) async {
  print("Calling from isolate");
  print(message);
}

class Conf {
  // void callback() {
  //   print("Callback");
  // }
  final Function callback;
  const Conf(this.callback);
}

class Act {
  void body() => print("I ran brother");
}

void main() async {
  await compute(spawn, () {});

  // final ReceivePort resultPort = ReceivePort();
  // final ReceivePort exitPort = ReceivePort();
  // final ReceivePort errorPort = ReceivePort();
  // final Isolate isolate = await Isolate.spawn(
  //   spawn,
  //   "",
  //   errorsAreFatal: true,
  //   onExit: exitPort.sendPort,
  //   onError: errorPort.sendPort,
  // );
  // final Completer result = Completer();
  // errorPort.listen((message) {
  //   print(message);
  // });
  // exitPort.listen((message) {
  //   print("Exit");
  //   print(message);
  // });
  // isolate.kill();
  // await result.future;
  // result.complete();
}
