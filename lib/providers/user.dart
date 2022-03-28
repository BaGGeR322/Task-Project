import 'dart:io';

import 'package:flutter/material.dart';

import '../helpers/dbhelper.dart';

class User {
  final String userName;
  final String email;
  final String password;
  final File image;

  User({
    required this.email,
    required this.password,
    required this.userName,
    required this.image,
  });
}

class UserLogInOrSignUp with ChangeNotifier {
  Future<void> signup(
    String _email,
    String _password,
    String _userName,
    File _image,
  ) async {
    await DBHelper.insert(DataBase.users, {
      'email': _email,
      'password': _password,
      'userName': _userName,
      'image': _image.path,
    });
  }
}
