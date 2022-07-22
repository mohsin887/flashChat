import 'package:chat_app/chat/messages.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserCardScreen extends StatefulWidget {
  final String username;
  final String status;
  final String senderId;
  const UserCardScreen({
    Key? key,
    required this.username,
    required this.status,
    required this.senderId,
  }) : super(key: key);

  @override
  State<UserCardScreen> createState() => _UserCardScreenState();
}

class _UserCardScreenState extends State<UserCardScreen> {
  bool isDeleteBy = false;

  void isUser() {
    final userDelete =
        Provider.of<UserProvider>(context, listen: false).user!.userDelete;
    FirebaseFirestore.instance.collection('users').doc(widget.senderId).update({
      'userDelete': !userDelete!,
    });
  }

  void isSender() {
    final senderDelete =
        Provider.of<UserProvider>(context, listen: false).user!.senderDelete;
    FirebaseFirestore.instance.collection('users').doc(widget.senderId).update({
      'senderDelete': !senderDelete!,
    });
  }

  void callChatScreen(
    String username,
    String userId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return ChatScreen(
          senderId: userId,
          username: username,
        );
      }),
    );
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference chat = FirebaseFirestore.instance.collection('chat');

  Future<void> deleteUser() {
    return users
        .doc(widget.senderId)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  Future<void> deleteChat(String user) {
    final userId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;
    final chatId = userId! + widget.senderId;
    if (user == userId) {
      return chat
          .doc(chatId)
          .delete()
          .then((value) => print("Chat Deleted"))
          .catchError((error) => print("Failed to delete chat: $error"));
    } else {
      return chat
          .doc(chatId)
          .delete()
          .then((value) => print("Chat Deleted"))
          .catchError((error) => print("Failed to delete chat: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.senderId)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
          if (userSnapshot.hasError) {
            return const Center(
              child: Text('SomeThing Went Wrong'),
            );
          }
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (userSnapshot.hasData) {
            final userDocuments = userSnapshot.data!;
            Map<String, dynamic> data =
                userDocuments.data() as Map<String, dynamic>;
            final userDelete = data['userDelete'];
            final senderDelete = data['senderDelete'];
            print('userDelete Value is $userDelete');
            print('senderDelete Value is $senderDelete');
            if (isDeleteBy ? userDelete : senderDelete) {
              return Container();
            }
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  callChatScreen(
                    widget.username,
                    widget.senderId,
                  );
                },
                title: Text(toBeginningOfSentenceCase(widget.username)!),
                subtitle: Text(widget.status),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    buildShowDialog(context);
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }

  Future<dynamic> buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Delete User'),
            content: const Text('Are you sure to delete this user?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              ),
              TextButton(
                onPressed: () {
                  isDeleteBy ? isUser() : isSender();
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
            ],
          );
        });
  }
}