import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/log_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/share_preference_screen.dart';
import '../../helper/user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final bool isSignUp = false;
  // bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    _userEmailController;
    _userNameController;
    _userPasswordController;
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      UserModel? userModel = await SharedPreferenceScreen().getUser(
          _userEmailController.text.trim(), _userPasswordController.text);

      if (userModel == null) {
        UserModel user = UserModel(
          username: _userNameController.text,
          password: _userPasswordController.text,
          email: _userEmailController.text,
          userId: DateTime.now().millisecond.toString(),
          userDelete: false,
          senderDelete: false,
        );
        if (!mounted) return;
        Provider.of<UserProvider>(context, listen: false).saveUser(user);
        SharedPreferenceScreen().saveUser(user);
        final userId =
            Provider.of<UserProvider>(context, listen: false).user?.userId;
        final userName =
            Provider.of<UserProvider>(context, listen: false).user?.username;

        final userEmail =
            Provider.of<UserProvider>(context, listen: false).user?.email;
        final userDelete =
            Provider.of<UserProvider>(context, listen: false).user?.userDelete;
        final senderDelete = Provider.of<UserProvider>(context, listen: false)
            .user
            ?.senderDelete;

        await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            FirebaseFirestore.instance.collection('users').doc(userId).set(
              {
                'username': userName,
                'email': userEmail,
                'status': 'Offline',
                'userId': userId,
                'userDelete': userDelete,
                'senderDelete': senderDelete,
              },
              SetOptions(merge: true),
            );
          }
        });
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const LogInScreen()),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email is already Exits'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _userEmailController.clear();
    _userNameController.clear();
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
                      key: const ValueKey('userName'),
                      controller: _userNameController,
                      validator: (value) {
                        _userNameController.text = value!;
                        if (value.isEmpty || value.length < 4) {
                          return 'Name must be at least 4 Character long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userNameController.text = value!;
                      },
                      decoration: const InputDecoration(labelText: 'User Name'),
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
                      onPressed: submit,
                      child: const Text(
                        'SignUp',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LogInScreen()));
                      },
                      child: const Text('I already have an account'),
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