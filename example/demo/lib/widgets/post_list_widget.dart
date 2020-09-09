import 'package:demo/models/models.dart';
import 'package:demo/refs.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart';

class PostList extends StatefulWidget {
  final int userId;
  PostList({Key key, this.userId}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final postStore = postsRef.store;
  @override
  Widget build(BuildContext context) {
    return StateBuilder<List<Post>>(
      stream: postStore.stream,
      initialState: postStore.state,
      waiting: (context) => Center(
        child: CircularProgressIndicator(),
      ),
      onData: (context, data) {
        var posts;
        if (widget.userId == null)
          posts = data;
        else

          /// This is only for example please avoid doing anything like this in production
          posts = postStore.filtered(widget.userId);
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(posts[index].title),
            isThreeLine: true,
            subtitle: Text(posts[index].body),
          ),
        );
      },
    );
  }
}
