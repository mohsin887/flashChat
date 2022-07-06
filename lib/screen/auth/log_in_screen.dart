import 'dart:io';

import 'package:chat_app/provider/auth.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/share_prefs.dart';
import '../../helper/user_model.dart';
import '../user_list_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool isLoading = true;
  final AuthMode _authMode = AuthMode.LogIn;
  final bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _userEmail;
    _userPassword;
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      UserModel? userModel = await Preference()
          .getUser(_userEmail.text.trim(), _userPassword.text);

      if (userModel != null) {
        Provider.of<UserProvider>(context, listen: false).saveUser(userModel);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const UserListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email is not Exit'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
    try {
      // final list = Provider.of<UserProvider>(context, listen: false).getUser();
/*
      bool isUserNotExist = list.any((element) =>
          element.email != _userEmail.text &&
          element.password != _userPassword.text);
      if (isUserNotExist) {
        print('Email is not exit');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email is not Exit'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        return;
      } else {
        print('User Exits is Login Now');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const UserListScreen()),
        );
        _userEmail.text = '';
        _userPassword.text = '';
      }*/
      // print("user: ${jsonEncode(loggedIn)}");
      // if (loggedIn != null &&
      //     loggedIn.password!.isNotEmpty &&
      //     loggedIn.email!.isNotEmpty) {
      //   print('<+++++++++++ USER SCREEN++++++>');
      //   print(loggedIn.toJson());
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (ctx) => const UserListScreen()),
      //   );
      // } else {
      //   print('<+++++++++++ AUTH SCREEN++++++>');
      //   print(loggedIn?.toJson());
      //
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content: const Text('User does not exit'),
      //         backgroundColor: Theme.of(context).colorScheme.secondary),
      //   );
      //   _userEmail.text = '';
      //   _userPassword.text = '';
      // }

    } on HttpException catch (error) {
      var errorMessage = 'Authenticate failed';
      if (error.message.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email is already in use';
      } else if (error.message.toString().contains('INVALID EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.message.toString().contains('WEAK_PASSWORD')) {
        errorMessage = ' This password is too weak';
      } else if (error.message.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = ' Could not find the user with that email';
      } else if (error.message.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      } else if (error.message.toString().contains('USER_DISABLED')) {
        errorMessage =
            'The user account has been disabled by an administrator.';
      }

      _showErrorDialog(errorMessage);
    } catch (err) {
      print("WHAT THE ERROR $err");
      const errMessage = 'Could not authenticate you. Please try again later';
      _showErrorDialog(errMessage);
      print("==============ERROR MESSAGE $errMessage");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userEmail.clear();
    _userPassword.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (value) {
                        _userEmail.text = value!;
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Please enter a vail email address';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userEmail.text = value!;
                      },
                      controller: _userEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    TextFormField(
                      maxLength: 6,
                      key: const ValueKey('password'),
                      controller: _userPassword,
                      validator: (value) {
                        _userPassword.text = value!;
                        if (value.isEmpty || value.length < 2) {
                          return 'Password must be at least 8 Character long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userPassword.text = value!;
                      },
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    // if (isLoading) const CircularProgressIndicator(),
                    // if (!isLoading)
                    Consumer<Auth>(
                      builder: (context, provider, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 8,
                            fixedSize: const Size(100, 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            provider.userId;
                            login();
                            if (isLogin) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const UserListScreen()));
                            }
                          },
                          child: const Text(
                            'LogIn',
                          ),
                        );
                      },
                    ),
                    // if (!isLoading)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const SignUpScreen()));
                      },
                      child: const Text('Create an Account'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
