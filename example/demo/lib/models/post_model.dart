class Post {
  final int userId, id;
  final String title, body;
  Post({this.id, this.userId, this.title, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        userId: json["userId"]);
  }
}
