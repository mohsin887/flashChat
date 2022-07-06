import 'package:chat_app/helper/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? user;
  String? userID;

  saveUser(UserModel user) async {
    this.user = user;
    userID = user.userId;

    print('=======USER MODEL USER $user==========USERID==========$userID');
    // await Preference().saveUser(user);
    notifyListeners();
  }

  getUser() async {
    // await Preference().getUser(email, password);

    print('=======USER MODEL===============$user');
    return user;
  }

  getUserId() {
    print('=======USER MODEL USER ID==========USERID==========$user');
    return userID;
  }
}
