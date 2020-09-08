import 'package:nano/nano.dart';
import 'stores/auth_store.dart';
import 'stores/stores.dart';
import 'stores/stores.dart';

final authRef = Pool.instance.register<AuthStore>(() => AuthStore());
final contactRef = Pool.instance.register<ContactStore>(() => ContactStore());
