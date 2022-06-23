import 'dart:io';

import 'package:chat_app/widget/authwidget/auth_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;
  final _auth = FirebaseAuth.instance;
  void _submitAuthForm(
    String email,
    String password,
    String username,
    XFile? image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential userCredential;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        userCredential.user?.updateDisplayName(username);
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredential.user!.uid}.jpg');
        final File imageFile = File(image!.path);

        await ref.putFile(imageFile);

        final url = await ref.getDownloadURL();
        // CollectionReference users =
        //     FirebaseFirestore.instance.collection('users');
        // users
        //     .where('userid', isEqualTo: userCredential.user?.uid)
        //     .limit(1)
        //     .get()
        //     .then((QuerySnapshot querySnapshot) {
        //   if (querySnapshot.docs.isEmpty) {
        //     FirebaseFirestore.instance
        //         .collection('users')
        //         .doc(userCredential.user?.uid)
        //         .set(
        //       {
        //         'username': username,
        //         'email': email,
        //         'image_url': url,
        //         'status': 'Available',
        //         'userid': userCredential.user?.uid,
        //       },
        //       SetOptions(merge: true),
        //     );
        //   }
        // });
        await FirebaseFirestore.instance
            .collection('users')
            .where('userid', isEqualTo: userCredential.user?.uid)
            .limit(1)
            .get()
            .then((QuerySnapshot querySnapshot) {
          if (querySnapshot.docs.isEmpty) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user?.uid)
                .set(
              {
                'username': username,
                'email': email,
                'image_url': url,
                'status': 'Offline',
                'userid': userCredential.user?.uid,
              },
              SetOptions(merge: true),
            );
          }
        });
      }
    } on FirebaseAuthException catch (error) {
      var message = 'An error occurred, please check with userCredential';
      if (error.message != null) {
        print('++++++++Error Message+++++++');
        print(error.message);

        message = error.message!;
      }
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
          backgroundColor: Theme.of(ctx).accentColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      print('++++++++Err+++++++');
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(
        _submitAuthForm,
        isLoading: _isLoading,
      ),
    );
  }
}
