import 'dart:io';

import 'package:demo/exceptions.dart';
import 'package:demo/models/models.dart';
import 'package:demo/refs.dart';
import 'package:demo/views/post_comments.dart';
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
      onError: (context, error) {
        if (error is SocketException)
          return Center(
              child: Icon(Icons.signal_cellular_connected_no_internet_4_bar));
        else if (error is InvalidRequest)
          return Center(child: Icon(Icons.error_outline));
        else
          return Center(child: Text("Something unexpected happened"));
      },
      onData: (context, data) {
        List<Post> posts;
        if (widget.userId == null)
          posts = data;
        else

          /// This is only for example please avoid doing anything like this in production
          posts = postStore.filtered(widget.userId);
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) => ListTile(
            onTap: () => Navigator.pushNamed(context, '/comments',
                arguments: PostCommentsArgs(posts[index].id)),
            title: Text(posts[index].title),
            isThreeLine: true,
            subtitle: Text(posts[index].body),
          ),
        );
      },
    );
  }
}
