import 'package:demo/models/models.dart';
import 'package:nano/nano.dart';

class CommentMutation {
  final List<CommentModel> comments;
  CommentMutation(this.comments);
}

class CommentStore extends Store<List<CommentModel>, CommentMutation> {
  @override
  bool get setInitialState => false;

  @override
  void reducer(CommentMutation mutation) {
    updateState(mutation.comments);
  }
}
