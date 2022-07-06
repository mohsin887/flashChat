import 'package:chat_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/share_prefs.dart';
import '../helper/user_model.dart';

class Auth extends ChangeNotifier {
  // String? _userName;
  // String? _userEmail;
  String? _userId;

  String? get userId {
    return _userId;
  }

  Future<void> signUp(
      String email, String name, String password, BuildContext context) async {
    UserModel user = UserModel(
      username: name,
      password: password,
      email: email,
      userId: DateTime.now().millisecond.toString(),
    );
    final userId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;
    print('========USER ID=======');
    print(userId);
    await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_userId.toString())
            .set(
          {
            'username': name,
            'email': email,
            'image_url': '_userImageFile',
            'status': 'Offline',
            'userId': userId,
          },
          SetOptions(merge: true),
        );
      }
    });
    Provider.of<UserProvider>(context, listen: false).saveUser(user);

    // await Preference().saveUser(user);
  }

  Future<void> login(String email, String password) async {
    await Preference().getUser(email, password);
  }
}
