import 'package:demo/database/database.dart';
import 'package:nano/nano.dart';

class DBMutation {
  final Database db;
  DBMutation(this.db);
}

class DbStore extends Store<Database, DBMutation> {
  @override
  bool get setInitialState => false;

  Map<String, dynamic> find(String username) => cData.find(username);

  @override
  void reducer(DBMutation mutation) {
    updateState(mutation.db);
  }
}