import 'dart:convert';

import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? username;
  String? password;
  String? email;
  String? userId;

  UserModel({
    this.username,
    this.password,
    this.email,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'email': email,
        'userId': userId,
      };

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      username: jsonData['username'],
      password: jsonData['password'],
      email: jsonData['email'],
      userId: jsonData['userId'],
    );
  }
  static Map<String, dynamic> toMap(UserModel user) => {
        'username': user.username,
        'password': user.password,
        'email': user.email,
        'userId': user.userId,
      };

  static List<UserModel> decode(String user) =>
      (json.decode(user) as List<dynamic>)
          .map<UserModel>((item) => UserModel.fromJson(item))
          .toList();

  static String encode(List<UserModel> user) => json.encode(
        user
            .map<Map<String, dynamic>>((user) => UserModel.toMap(user))
            .toList(),
      );
}
