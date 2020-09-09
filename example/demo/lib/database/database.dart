// Mock implementation of a database
import 'package:demo/database/user_data.dart';

class Database {
  bool initialized = false;

  Future<void> initialize() async {
    await Future.delayed(Duration(seconds: 3));
    initialized = true;
  }

  Map<String, dynamic> find(String username) {
    if (initialized) {
      for (var user in kuserData) {
        if (user["username"] == username) return user;
      }
      return null;
    } else
      throw Exception("Database is not initialized");
  }
}
