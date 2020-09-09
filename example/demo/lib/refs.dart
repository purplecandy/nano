import 'stores/stores.dart';
import 'package:nano/nano.dart';

final authRef = Pool.instance.register(() => AuthStore());
final dbRef = Pool.instance.register(() => DbStore());
final postsRef = Pool.instance.register(() => PostStore());
final commentsRef = Pool.instance.register(() => CommentStore());
