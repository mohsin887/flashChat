import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/log_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/share_prefs.dart';
import '../../helper/user_model.dart';

enum AuthMode { SignUp, LogIn }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userEmail = TextEditingController();
  final TextEditingController _userPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthMode _authMode = AuthMode.SignUp;

  final bool isLoading = true;
  final bool isSignUp = false;

  @override
  void initState() {
    super.initState();
    _userEmail;
    _userName;
    _userPassword;
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      UserModel? userModel = await Preference()
          .getUser(_userEmail.text.trim(), _userPassword.text);

      if (userModel == null) {
        UserModel user = UserModel(
          username: _userName.text,
          password: _userPassword.text,
          email: _userEmail.text,
          userId: DateTime.now().millisecond.toString(),
        );

        Provider.of<UserProvider>(context, listen: false).saveUser(user);
        Preference().saveUser(user);
        final userId =
            Provider.of<UserProvider>(context, listen: false).user?.userId;
        print('USER ID: $userId');
        final userName =
            Provider.of<UserProvider>(context, listen: false).user?.username;
        print('USER NAME: $userName');

        final userEmail =
            Provider.of<UserProvider>(context, listen: false).user?.email;
        print('USER EMAILS IS: $userEmail');

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
                // 'image_url': '_userImageFile',
                'status': 'Offline',
                'userId': userId,
              },
              SetOptions(merge: true),
            );
          }
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const LogInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email is already Exits'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    }
    /*List<UserModel>? list = await Preference().getUserList();
    // final list = Provider.of<UserProvider>(context, listen: false).getUser();

    bool isUserAlreadyExist =
        list.any((element) => element.email == _userEmail.text);
    if (isUserAlreadyExist) {
      print('email is already used');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email is already Exits'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    } else {
      UserModel user = UserModel(
        username: _userName.text,
        password: _userPassword.text,
        email: _userEmail.text,
        userId: DateTime.now().millisecond.toString(),
      );
      print('===========USER MODEL USER===========: $user');
      Provider.of<UserProvider>(context, listen: false).saveUser(user);
      print(
          '===========SAVE USER IN PROVIDER============}: ${Provider.of<UserProvider>(context, listen: false).getUser()}');
      // print('===========SAVE USER IN SHARED PREFERENCE============}');
      print(Preference().saveUser(user));
      // await Preference().saveUser(user);

      final userId =
          Provider.of<UserProvider>(context, listen: false).user?.userId;
      print('========USER ID=======: $userId');
      final userName =
          Provider.of<UserProvider>(context, listen: false).user?.username;
      print('========USER NAME======= $userName');
      final userEmail =
          Provider.of<UserProvider>(context, listen: false).user?.email;
      print('========USER EMAIL=======: $userEmail');
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
              'image_url': '_userImageFile',
              'status': 'Offline',
              'userId': userId,
            },
            SetOptions(merge: true),
          );
        }
      });

      // await Provider.of<Auth>(context, listen: false)
      //     .signUp(_userEmail.text, _userName.text, _userPassword.text, context);
      // Provider.of<UserProvider>(context, listen: false).saveUser(user);
      // print(Provider.of<Auth>(context, listen: false).signUp(
      //     _userEmail.text, _userName.text, _userPassword.text, context));
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LogInScreen()));
    }*/
  }

  @override
  void dispose() {
    _userEmail.clear();
    _userName.clear();
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
                    // if (!_isLogin)
                    //   UserImagePicker(imagePickFn: (XFile image) {
                    //     _userImageFile = image;
                    //   }),
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
                      key: const ValueKey('userName'),
                      controller: _userName,
                      validator: (value) {
                        _userName.text = value!;
                        if (value.isEmpty || value.length < 4) {
                          return 'Name must be at least 4 Character long';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        _userName.text = value!;
                        print("ON SAVED USER NAME");
                        print(_userName);
                      },
                      decoration: const InputDecoration(labelText: 'User Name'),
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
