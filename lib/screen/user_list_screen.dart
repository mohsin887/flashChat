import 'dart:async';

import 'package:chat_app/chat/user_bubble.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/share_prefs.dart';
import 'auth/log_in_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
  }

  Future<void> setStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({
        'status': status,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus('Online');
    } else {
      setStatus('Offline');
    }
    super.didChangeAppLifecycleState(state);
  }

  // var currentUser = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).getUserId();
    print('USER ID IS $currentUser');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          DropdownButton(
            underline: Container(),
            items: [
              DropdownMenuItem(
                value: 'Logout',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onChanged: (itemsIdentifier) async {
              if (itemsIdentifier == 'Logout') {
                // FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => const LogInScreen(),
                  ),
                );
                await Preference().removeAllData();
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).accentColor,
            ),
          )
        ],
      ),
      // body: FutureBuilder(
      //   future: FirebaseAuth.instance.currentUser?.reload(),
      //   builder: (ctx, futureSnapshot) {
      //     if (futureSnapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(
                'users',
              )
              .where('userId', isNotEqualTo: currentUser)
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final chatDocuments = chatSnapshot.data?.docs;
            print(chatDocuments?.length);
            return ListView.builder(
              itemBuilder: (ctx, index) {
                return UserBubble(
                  senderId: chatDocuments![index]['userId'],
                  status: chatDocuments[index]['status'],
                  username: chatDocuments[index]['username'],
                  // imageUrl: chatDocuments[index]['image_url'],
                  key: ValueKey(chatDocuments[index].id),
                );
              },
              itemCount: chatDocuments!.length,
            );
          }),
    );
  }
}
