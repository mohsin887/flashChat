import 'dart:async';

import 'package:chat_app/chat/user_bubble.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/auth/log_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/share_prefs.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with WidgetsBindingObserver {
  // final String uuid = GUIDGen.generate();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // setStatus('Online');
  }

  Future<void> setStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'status': status,
    });
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
  // var currentUser = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).userID;
    print('USER ID IN USERS: $user');
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) => const LogInScreen(),
                  ),
                );
                await Preference().removeAllData();

                // FirebaseAuth.instance.signOut();
                // final prefs = await SharedPreferences.getInstance();
                //
                // prefs.clear();
              }
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
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
      //     // const userId = 'userId';
      //     return
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(
                'users',
              )
              .where('userid', isNotEqualTo: user)
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final chatDocuments = chatSnapshot.data?.docs;
            // chatDocuments!
            //     .removeWhere((element) => element.id == '1656656912267');
            return ListView.builder(
              itemBuilder: (ctx, index) {
                return UserBubble(
                  senderId: chatDocuments![index]['userid'],
                  status: chatDocuments[index]['status'],
                  username: chatDocuments[index]['username'],
                  imageUrl: chatDocuments[index]['image_url'],
                  key: ValueKey(chatDocuments[index].id),
                );
              },
              itemCount: chatDocuments!.length,
            );
          }),
    );

    // body: const Center(
    //   child: Text('Welcome to USerScreen'),
    // ),
  }
}
