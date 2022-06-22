import 'package:chat_app/chat/messages.dart';
import 'package:chat_app/chat/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String senderId;
  const ChatScreen({
    Key? key,
    required this.username,
    required this.imageUrl,
    required this.senderId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     widget.username,
      //     style: const TextStyle(
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      body: SizedBox(
        child: Column(
          children: [
            Expanded(
              child: Messages(
                senderId: widget.senderId, senderName: widget.username,
                senderImage: widget.imageUrl,
                // receiverId: widget.receiverId,
                // userMap: {},
              ),
            ),
            // const NewMessages(),
          ],
        ),
      ),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: FirebaseFirestore.instance
      //       .collection('chats/I4WRnaeP7huTw7I0RmWE/messages')
      //       .snapshots(),
      //   builder: (ctx, streamSnapshot) {
      //     if (streamSnapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     final documents = streamSnapshot.data?.docs;
      //     return ListView.builder(
      //       itemCount: documents?.length,
      //       shrinkWrap: true,
      //       reverse: true,
      //       physics: const NeverScrollableScrollPhysics(),
      //       itemBuilder: (context, index) => Center(
      //         child: Text(documents![index]['text']),
      //       ),
      //     );
      //   },
      // ),
      //
    );
  }
}
