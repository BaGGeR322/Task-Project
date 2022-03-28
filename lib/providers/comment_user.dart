import 'package:flutter/material.dart';

import 'user.dart';

class CommentUser with ChangeNotifier {
  // final User user;
  // final String email; // нужен для того, чтобы была возможность удалять комментарий от его лица
  final String image;
  final String userName;
  final DateTime dateTime; // как айди будет использоваться
  final String comment;

  CommentUser(
    // this.email,
    this.image,
    this.userName,
    this.dateTime,
    this.comment,
  );

  Future<void> addComment() async {}
}

class Comments with ChangeNotifier {
  List<CommentUser> _items = [];

  List<CommentUser> get items {
    return [..._items];
  }


}