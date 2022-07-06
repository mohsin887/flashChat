import 'package:chat_app/helper/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  String? userID;

  saveUser(UserModel user) async {
    this.user = user;
    userID = user.userId;
    notifyListeners();
  }

  getUser() async {
    return user;
  }

  getUserId() {
    return userID;
  }
}
