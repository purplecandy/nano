import 'package:demo/database/database.dart';
import 'package:demo/refs.dart';
import 'package:demo/stores/stores.dart';
import 'package:nano/nano.dart';

class DatabaseActions {
  static final create = ActionRef<void, Database>(
    body: (_) async {
      final db = Database();
      await db.initialize();
      return db;
    },
    store: (_) => dbRef.store,
    mutation: (db, __) => DBMutation(db),
  );
}
