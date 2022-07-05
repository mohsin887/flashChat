// import 'dart:convert';
//
// import 'package:chat_app/helper/user_model.dart';
// import 'package:chat_app/provider/user_provider.dart';
// import 'package:chat_app/provider/users.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../helper/share_prefs.dart';
// import '../../screen/auth_screen.dart';
// import '../../screen/user_list_screen.dart';
//
// class AuthForm extends StatefulWidget {
//   const AuthForm({
//     Key? key,
//     required this.isLoading,
//   }) : super(key: key);
//
//   final bool isLoading;
//
//   // final void Function(
//   //   String email,
//   //   String password,
//   //   String username,
//   //   // XFile? image,
//   //   bool isLogin,
//   //   BuildContext cntx,
//   // ) submitFn;
//
//   @override
//   State<AuthForm> createState() => _AuthFormState();
// }
//
// class _AuthFormState extends State<AuthForm> {
//   final TextEditingController _userName = TextEditingController();
//   final TextEditingController _userEmail = TextEditingController();
//   final TextEditingController _userPassword = TextEditingController();
//   UserModel? loggedInUser;
//
//   @override
//   void initState() {
//     super.initState();
//     _userEmail;
//     _userName;
//     _userPassword;
//   }
//
//   final prefs = SharedPreferences.getInstance();
//   final _prefernce = Preference();
//   final _formKey = GlobalKey<FormState>();
//   var _isLogin = true;
//
//   // var _userEmail = '';
//
//   // var _userName = '';
//
//   // var _userPassword = '';
//
//   // final _userId = UniqueKey().hashCode.toString();
//   final _userId = DateTime.now().millisecondsSinceEpoch;
//
//   XFile? _userImageFile;
//   final _isLoading = false;
//
//   // void _pickedImage(XFile? image) {
//   //   _userImageFile = (image == null ? null : <XFile>[image]) as XFile?;
//   // }
//
//   // void _trySubmit() {
//   //   final isValid = _formKey.currentState!.validate();
//   //   FocusScope.of(context).unfocus();
//   //
//   //   if (_userImageFile == null && !_isLogin) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         content: const Text('Please pick an image'),
//   //         backgroundColor: Theme.of(context).errorColor,
//   //       ),
//   //     );
//   //     return;
//   //   }
//   //   if (isValid) {
//   //     _formKey.currentState!.save();
//   //     widget.submitFn(
//   //       _userEmail.trim(),
//   //       _userPassword.trim(),
//   //       _userName.trim(),
//   //       _userImageFile,
//   //       _isLogin,
//   //       context,
//   //     );
//   //     return;
//   //   }
//   // }
//
//   signUp() async {
//     try {
//       // setState(() {
//       //   _isLoading = true;
//       // });
//       if (!_formKey.currentState!.validate()) {
//         return;
//       }
//       UserModel user = UserModel(
//         username: _userName.text,
//         password: _userPassword.text,
//         email: _userEmail.text,
//         userId: _userId.toString(),
//       );
//       // List<UserModel>? list = await Provider.of<Users>(context).getUserList();
//       List<UserModel>? list = await Preference().getUserList();
//       bool isUserAlreadyExist =
//           list.any((element) => element.email == _userEmail.text);
//       if (isUserAlreadyExist) {
//         print('email is already used');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Email is already Exits'),
//             backgroundColor: Theme.of(context).colorScheme.secondary,
//           ),
//         );
//         return;
//       }
//       await FirebaseFirestore.instance
//           .collection('users')
//           .where('userid', isEqualTo: _userId)
//           .limit(1)
//           .get()
//           .then((QuerySnapshot querySnapshot) {
//         if (querySnapshot.docs.isEmpty) {
//           FirebaseFirestore.instance
//               .collection('users')
//               .doc(_userId.toString())
//               .set(
//             {
//               'username': _userName.text,
//               'email': _userEmail.text,
//               'image_url': '_userImageFile',
//               'status': 'Offline',
//               'userid': _userId.toString(),
//             },
//             SetOptions(merge: true),
//           );
//         }
//       });
//       // await Preference().saveUser(user);
//       Provider.of<Users>(context).setUser(user);
//     } on PlatformException catch (error) {
//       var message = 'An error occurred, please check with userCredential';
//       if (error.message != null) {
//         print('++++++++Error Message+++++++');
//         print(error.message);
//
//         message = error.message!;
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             message,
//           ),
//           backgroundColor: Theme.of(context).colorScheme.secondary,
//         ),
//       );
//       // setState(() {
//       //   _isLoading = false;
//       // });
//     } catch (err) {
//       // setState(() {
//       //   _isLoading = false;
//       // });
//       print('++++++++Err+++++++');
//       print(err);
//     }
//     print('<+++++++++++ USER SCREEN++++++>');
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (ctx) => const AuthScreen()),
//     );
//   }
//
//   login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     UserModel? loggedIn = await Provider.of<Users>(context, listen: false)
//         .getUsers(_userEmail.text, _userPassword.text);
//
//     // loggedInUser = await Preference().getUser(
//     //   _userEmail.text,
//     //   _userPassword.text,
//     // );
//     print("user: ${jsonEncode(loggedIn)}");
//     if (loggedIn != null &&
//         loggedIn.password!.isNotEmpty &&
//         loggedIn.email!.isNotEmpty) {
//       print('<+++++++++++ USER SCREEN++++++>');
//       print(loggedIn.toJson());
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (ctx) => const UserListScreen()),
//       );
//     } else {
//       print('<+++++++++++ AUTH SCREEN++++++>');
//       print(loggedIn?.toJson());
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: const Text('User does not exit'),
//             backgroundColor: Theme.of(context).colorScheme.secondary),
//       );
//       _userEmail.text = '';
//       _userPassword.text = '';
//     }
//   }
//
//   @override
//   void dispose() {
//     _userEmail.clear();
//     _userName.clear();
//     _userPassword.clear();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // if (!_isLogin)
//                   //   UserImagePicker(imagePickFn: (XFile image) {
//                   //     _userImageFile = image;
//                   //   }),
//                   TextFormField(
//                     key: const ValueKey('email'),
//                     validator: (value) {
//                       _userEmail.text = value!;
//                       if (value.isEmpty || !value.contains('@')) {
//                         return 'Please enter a vail email address';
//                       } else {
//                         return null;
//                       }
//                     },
//                     onSaved: (value) {
//                       _userEmail.text = value!;
//                     },
//                     controller: _userEmail,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: 'Email Address',
//                     ),
//                   ),
//                   if (!_isLogin)
//                     TextFormField(
//                       key: const ValueKey('userName'),
//                       controller: _userName,
//                       validator: (value) {
//                         _userName.text = value!;
//                         if (value.isEmpty || value.length < 4) {
//                           return 'Name must be at least 4 Character long';
//                         } else {
//                           return null;
//                         }
//                       },
//                       onSaved: (value) {
//                         _userName.text = value!;
//                         print("ON SAVED USER NAME");
//                         print(_userName);
//                       },
//                       decoration: const InputDecoration(labelText: 'User Name'),
//                     ),
//                   TextFormField(
//                     key: const ValueKey('password'),
//                     controller: _userPassword,
//                     validator: (value) {
//                       _userPassword.text = value!;
//                       if (value.isEmpty || value.length < 2) {
//                         return 'Password must be at least 8 Character long';
//                       } else {
//                         return null;
//                       }
//                     },
//                     onSaved: (value) {
//                       _userPassword.text = value!;
//                     },
//                     decoration: const InputDecoration(labelText: 'Password'),
//                     obscureText: true,
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   if (widget.isLoading) const CircularProgressIndicator(),
//                   if (!widget.isLoading)
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         elevation: 8,
//                         fixedSize: const Size(100, 10),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       onPressed: _isLogin ? login : signUp,
//                       child: Text(
//                         _isLogin ? 'Login' : 'SignUp',
//                       ),
//                     ),
//                   if (!widget.isLoading)
//                     TextButton(
//                       onPressed: () {
//                         setState(() {
//                           _isLogin = !_isLogin;
//                         });
//                       },
//                       child: Text(_isLogin
//                           ? 'Create an account'
//                           : 'I already have an account'),
//                     )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
