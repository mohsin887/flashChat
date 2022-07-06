import 'package:chat_app/chat/messages.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String senderId;
  const ChatScreen({
    Key? key,
    required this.username,
    required this.senderId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Messages(
                senderId: widget.senderId,
                senderName: widget.username,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
