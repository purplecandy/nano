import 'package:demo/actions/actions.dart' as actions;
import 'package:demo/models/models.dart';
import 'package:demo/refs.dart';
import 'package:demo/values/colors.dart';
import 'package:demo/widgets/comment_list.dart';
import 'package:flutter/material.dart';
import 'package:nano/nano.dart' as n;

import '../refs.dart';

class PostCommentsArgs {
  final int id;
  PostCommentsArgs(this.id);
}

class PostCommnetsRoute extends StatelessWidget {
  const PostCommnetsRoute({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PostCommentsArgs args = ModalRoute.of(context).settings.arguments;
    return n.StoreManager(
      recreatable: [commentsRef],
      uninitialize: [commentsRef],
      child: PostCommentsView(postId: args.id),
    );
  }
}

class PostCommentsView extends StatefulWidget {
  final int postId;
  PostCommentsView({Key key, this.postId}) : super(key: key);

  @override
  _PostCommentsViewState createState() => _PostCommentsViewState();
}

class _PostCommentsViewState extends State<PostCommentsView> {
  @override
  void initState() {
    super.initState();
    n.Action(
      () => actions.fetchComments(widget.postId),
      onError: (e) => [n.Mutation(postsRef.store, e.toString())],
    ).run();
    
    // n.PostActions.fetchComments(
    //     payload: widget.postId,
    //     onError: (e) => [
    //           Mutation(postsRef.store, e.toString()),
    //         ]).run();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundBlue,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Post Comments",
          style: TextStyle(color: ColorPalette.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: n.StateBuilder<List<CommentModel>>(
        initialState: commentsRef.store.state,
        stream: commentsRef.store.stream,
        waiting: (context) => Center(child: CircularProgressIndicator()),
        onError: (context, error) => Center(child: Text(error)),
        onData: (context, comments) => CommentList(comments: comments),
      ),
    );
  }
}
