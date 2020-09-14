import 'package:demo/models/models.dart';
import 'package:nano/nano.dart';

class AddPostMutation {
  final List<Post> posts;
  AddPostMutation(this.posts);
}

class PostStore extends Store<List<Post>, AddPostMutation> {
  @override
  bool get setInitialState => false;

  List<Post> filtered(int userId) =>
      cData.where((element) => element.userId == userId).toList();

  @override
  void reducer(AddPostMutation mutation) {
    if (cData == null)
      updateState(mutation.posts);
    else {
      cData.addAll(mutation.posts);
      updateState(cData);
    }
  }
}
