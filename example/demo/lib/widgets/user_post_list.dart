import 'package:demo/models/auth_model.dart';
import 'package:demo/refs.dart';
import 'package:demo/widgets/post_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

class UserPosts extends StatelessWidget {
  const UserPosts({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StateBuilder<AuthModel>(
      initialState: authRef.store.state,
      stream: authRef.store.stream,
      waiting: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Waiting for Database to initialize"),
          Container(
              width: 70,
              padding: const EdgeInsets.all(8),
              child: LinearProgressIndicator()),
        ],
      ),
      onData: (context, data) {
        switch (data.state) {
          case AuthState.authorized:
            return PostList(
              userId: data.user.id,
            );
            break;
          default:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You need to login"),
                FlatButton(
                    color: Colors.lightGreen,
                    onPressed: () {
                      Navigator.pushNamed(context, '/auth');
                    },
                    child: Text("Authenticate")),
              ],
            );
        }
      },
    );
  }
}
