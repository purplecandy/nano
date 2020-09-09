import 'package:demo/models/models.dart';
import 'package:flutter/material.dart';

class CommentList extends StatelessWidget {
  final List<CommentModel> comments;
  const CommentList({Key key, this.comments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(comments[index].name),
        isThreeLine: true,
        subtitle: Text(comments[index].body),
      ),
    );
  }
}
