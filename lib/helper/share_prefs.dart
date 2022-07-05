import 'package:chat_app/helper/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class Preference extends ChangeNotifier {
  String userList = "USER_LIST";

  Future saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    List<UserModel> list = await getUserList();

    list.add(user);

    print('<======== LIST USER SAVE ========> ${UserModel.encode(list)}');
    prefs.setString(userList, UserModel.encode(list));
  }

  Future<UserModel?> removeAllData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    return null;
  }

  Future<List<UserModel>> getUserList() async {
    final prefs = await SharedPreferences.getInstance();

    String? listString = prefs.getString(userList);

    print(' <======== LIST STRING ========> : $listString');
    List<UserModel>? list =
        listString != null ? UserModel.decode(listString) : [];

    /*(listString != null ? jsonDecode(listString) as List : []).cast<User>();*/
    return list;
  }

  Future<UserModel?> getUser(String email, String password) async {
    List<UserModel> list = await getUserList();

    if (list.isNotEmpty) {
      return list.firstWhereOrNull(
          (element) => element.email == email && element.password == password);
    } else {
      return null;
    }
  }
}
