import 'package:chat_app/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
