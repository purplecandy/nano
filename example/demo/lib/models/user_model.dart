class User {
  final int id;
  final String username, name, email;
  User({this.id, this.username, this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json["username"],
      name: json["name"],
      email: json["email"],
    );
  }
}
