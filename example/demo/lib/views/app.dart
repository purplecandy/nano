import 'package:demo/actions/actions.dart';
import 'package:demo/database/database.dart';
import 'package:demo/refs.dart';
import 'package:demo/views/authenticate.dart';
import 'package:demo/views/post_comments.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';
import 'home.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  static final navigator = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    DatabaseActions.create().run();
    dbRef.store.addWorker(Worker<Database>((db) => db.initialized, () {
      print("Database Intnitialized");
      // navigator.currentState.pushNamed('/auth');
    }, limit: 1));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigator,
      title: 'Demo App',
      initialRoute: '/',
      routes: {
        '/': (context) =>
            StoreManager(initialize: [postsRef], child: HomeView()),
        '/auth': (context) => AuthentiateView(),
        '/comments': (context) => PostCommnetsRoute(),
      },
    );
  }
}
