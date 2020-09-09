class ApiUrls {
  static final posts = "https://jsonplaceholder.typicode.com/posts";
  static postComments(int id) =>
      "https://jsonplaceholder.typicode.com/posts/$id/comments";
}
