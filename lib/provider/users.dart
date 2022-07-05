import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/share_prefs.dart';
import '../helper/user_model.dart';

class Users with ChangeNotifier {
  List<UserModel> _users = [];
  String? userID;
  UserModel? users;

  getUserId() {
    return _users;
  }

  List<UserModel> get user {
    return [..._users];
  }

  UserModel findById(String id) {
    return _users.firstWhere((prod) => prod.userId == id);
  }

  UserModel getUse(String email, String password) {
    return _users.firstWhere(
        (element) => element.email == email && element.password == password);
  }

  Future<UserModel?> getUsers(String email, String password) async {
    List<UserModel>? list = await Preference().getUserList();
    if (list.isNotEmpty) {
      return list.firstWhere(
        (element) => element.email == email && element.password == password,
      );
    }
    _users = list;
    print('============GET USER LIST$list============');
    notifyListeners();
    return null;
  }

  Future<UserModel?> setUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    List<UserModel> list = await getUserList();

    _users.add(user);
    prefs.setString(userList, UserModel.encode(list));

    updateSharedPrefrences();
    notifyListeners();
    return null;
  }

  Future<UserModel?> removeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userList);
    updateSharedPrefrences();
    notifyListeners();
    return null;
  }

  String userList = "USER_LIST";

  Future updateSharedPrefrences() async {
    List<String> myCards = user.map((f) => json.encode(f.toJson())).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(userList, myCards);
  }

  Future<List<UserModel>> getUserList() async {
    final prefs = await SharedPreferences.getInstance();

    String? listString = prefs.getString(userList);

    print("<======== LIST STRING ========>");
    print(listString);
    List<UserModel>? list =
        listString != null ? UserModel.decode(listString) : [];
    notifyListeners();
    /*(listString != null ? jsonDecode(listString) as List : []).cast<User>();*/
    return list;
  }

  Future<UserModel?> getUser(
    String email,
    String password,
  ) async {
    List<UserModel>? list = await getUserList();
    if (list.isNotEmpty) {
      return list.firstWhere(
        (element) => element.email == email && element.password == password,
      );
    } else {
      return null;
    }
  }
}
