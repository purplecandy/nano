import 'package:demo/actions/actions.dart';
import 'package:demo/actions/actions.dart' as actions;
import 'package:flutter/material.dart' hide Action;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nano/nano.dart';

class AuthentiateView extends StatefulWidget {
  AuthentiateView({Key key}) : super(key: key);

  @override
  _AuthentiateViewState createState() => _AuthentiateViewState();
}

class _AuthentiateViewState extends State<AuthentiateView> {
  final _username = TextEditingController();
  void hanldeOnTap() {
    
    Action(() => actions.signIn(_username.text.trim()), onError: (e) {
      Fluttertoast.showToast(msg: "Invalid credentials");
      return null;
    }, onDone: () {
      Fluttertoast.showToast(msg: "Success");
      Navigator.pop(context);
    }).run();

    // AuthActions.signIn(
    //     payload: _username.text.trim(),
    //     onError: (e) {
    //       Fluttertoast.showToast(msg: "Invalid credentials");
    //       return null;
    //     },
    //     onDone: () {
    //       Fluttertoast.showToast(msg: "Success");
    //       Navigator.pop(context);
    //     }).run();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Authenticate"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _username,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Username"),
              ),
            ),
            Text('Try invalid username first'),
            Text("Correct username: Bret"),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: hanldeOnTap,
        ),
      ),
    );
  }
}
