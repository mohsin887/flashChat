import 'dart:convert';

import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? username;
  String? password;
  String? email;
  String? userId;
  bool? userDelete;
  bool? senderDelete;

  UserModel({
    this.username,
    this.password,
    this.email,
    this.userId,
    this.userDelete,
    this.senderDelete,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'email': email,
        'userId': userId,
        'userDelete': userDelete,
        'senderDelete': senderDelete,
      };

  factory UserModel.fromJson(Map<String, dynamic> jsonData) {
    return UserModel(
      username: jsonData['username'],
      password: jsonData['password'],
      email: jsonData['email'],
      userId: jsonData['userId'],
      userDelete: jsonData['userDelete'],
      senderDelete: jsonData['senderDelete'],
    );
  }
  static Map<String, dynamic> toMap(UserModel user) => {
        'username': user.username,
        'password': user.password,
        'email': user.email,
        'userId': user.userId,
        'userDelete': user.userDelete,
        'senderDelete': user.senderDelete,
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