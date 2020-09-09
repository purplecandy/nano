import 'dart:convert';

import 'package:flutter/material.dart';

class CommentModel {
  final int postId, id;
  final String name, email, body;
  CommentModel({this.postId, this.id, this.name, this.email, this.body});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      postId: json['postId'],
      id: json["id"],
      name: json["name"],
      body: json["body"],
      email: json["email"],
    );
  }
}
