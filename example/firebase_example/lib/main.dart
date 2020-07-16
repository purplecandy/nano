import 'package:firebase_example/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nano/nano.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final _authState = AuthState();
  @override
  void initState() {
    super.initState();
    _authState.init(FirebaseAuth.instance.onAuthStateChanged);
    // auth();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.subdirectory_arrow_right),
              onPressed: () => _authState.dispatch(AuthActions.signIn,
                  initialProps: Prop.success(
                      Credentials("example@example.com", "example")))),
          IconButton(
              icon: Icon(Icons.subdirectory_arrow_left),
              onPressed: () => _authState.dispatch(AuthActions.signOut))
        ],
      ),
      body: StateBuilder<FirebaseUser>(
        initialState: _authState.state,
        stream: _authState.stream,
        onError: (context, error) => Center(child: Text("Error: " + error)),
        onData: (context, data) {
          switch (data) {
            case null:
              return Center(
                child: Text("Unauthorised"),
              );
              break;

            default:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
