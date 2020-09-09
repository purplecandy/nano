import 'dart:convert';

import 'package:demo/api/api.dart';
import 'package:demo/exceptions.dart';
import 'package:demo/refs.dart';
import 'package:demo/stores/stores.dart';
import 'package:http/http.dart' as http;
import 'package:demo/models/models.dart';
import 'package:nano/nano.dart';

class PostActions {
  static final fetch = ActionRef<void, List<Post>>(
      body: (_) async {
        final url = ApiUrls.posts;
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final jsonData = json.decode(resp.body);
          final List<Post> posts = [];
          for (var item in jsonData) {
            posts.add(Post.fromJson(item));
          }
          return posts;
        } else {
          throw InvalidRequest();
        }
      },
      mutation: (posts, _) => AddPostMutation(posts),
      store: (_) => postsRef.store);
}
