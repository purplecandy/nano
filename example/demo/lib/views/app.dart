import 'package:flutter/material.dart';
import 'home.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  static final navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigator,
      title: 'Demo App',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeView(),
      },
    );
  }
}
