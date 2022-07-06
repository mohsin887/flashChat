import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

import 'package:chat_app/screen/user_card_screen.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helper/share_preference_screen.dart';
import 'auth/log_in_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // setStatus('Online');
  }

  // Future<void> setStatus(String status) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser?.uid)
  //         .update({
  //       'status': status,
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // setStatus('Online');
    } else {
      // setStatus('Offline');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).getUserId();
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
                await SharedPreferenceScreen().removeAllData();
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).accentColor,
            ),
          )
        ],
      ),
      body: getUsersStreamBuilder(currentUser),
    );
  }

  Widget getUsersStreamBuilder(currentUser) {
    return StreamBuilder<QuerySnapshot>(
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
        return ListView.builder(
          itemBuilder: (ctx, index) {
            return UserCardScreen(
              senderId: chatDocuments![index]['userId'],
              status: chatDocuments[index]['status'],
              username: chatDocuments[index]['username'],
              key: ValueKey(chatDocuments[index].id),
            );
          },
          itemCount: chatDocuments!.length,
        );
      },
    );
  }
}
