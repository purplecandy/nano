import 'package:flutter/material.dart';

class ShowError extends StatelessWidget {
  final Object error;
  const ShowError({Key key, this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline),
          Text("Whoops! Something unexpected happend"),
          Text(error),
        ],
      ),
    );
  }
}
