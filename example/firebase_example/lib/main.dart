import 'package:firebase_example/utils.dart';
import 'package:firebase_example/views/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:auth/auth.dart';

class Val extends ChangeNotifier {
  int n = 20;

  change() async {
    await Future.delayed(Duration(seconds: 5));
    n = 40;
    notifyListeners();
  }
}

//No need to dispose the providers declared here as they are app level now
void main() => runApp(MultiProvider(providers: [
      Provider<AuthState>(
        create: (_) {
          return AuthState()..init(FirebaseAuth.instance.onAuthStateChanged);
        },
      ),
      ChangeNotifierProvider<Val>(
        create: (_) {
          return Val()..change();
        },
      )
    ], child: App()));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/": (context) => HomePage(authState: grab<AuthState>(context)),
      },
    );
  }
}
