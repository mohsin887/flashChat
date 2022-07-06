import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/share_preference_screen.dart';
import '../../helper/user_model.dart';
import '../users_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _userEmailController;
    _userPasswordController;
  }

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      UserModel? userModel = await SharedPreferenceScreen().getUser(
          _userEmailController.text.trim(), _userPasswordController.text);
      if (userModel != null) {
        Provider.of<UserProvider>(context, listen: false).saveUser(userModel);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const UsersScreen()),
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
  }

  @override
  void dispose() {
    _userEmailController.clear();
    _userPasswordController.clear();
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
                        _userEmailController.text = value!;
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Please enter a vail email address';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userEmailController.text = value!;
                      },
                      controller: _userEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                    ),
                    TextFormField(
                      maxLength: 6,
                      key: const ValueKey('password'),
                      controller: _userPasswordController,
                      validator: (value) {
                        _userPasswordController.text = value!;
                        if (value.isEmpty || value.length < 2) {
                          return 'Password must be at least 8 Character long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userPasswordController.text = value!;
                      },
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        fixedSize: const Size(100, 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: login,
                      child: const Text(
                        'LogIn',
                      ),
                    ),
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
