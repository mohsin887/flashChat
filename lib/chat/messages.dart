import 'package:chat_app/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: FirebaseAuth.instance.currentUser?.reload(),
      builder: (ctx, futureSnapshot) {
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat')
                .orderBy(
                  'createdAt',
                  descending: true,
                )
                .snapshots(),
            builder: (ctx, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final chatDocuments = chatSnapshot.data?.docs;
              return ListView.builder(
                reverse: true,
                itemBuilder: (ctx, index) {
                  return MessageBubble(
                    message: chatDocuments![index]['text'],
                    userName: chatDocuments[index]['username'],
                    userImage: chatDocuments[index]['userImage'],
                    isMe: chatDocuments[index]['userId'] ==
                        FirebaseAuth.instance.currentUser!.uid,
                    key: ValueKey(chatDocuments[index].id),
                  );
                },
                itemCount: chatDocuments!.length,
              );
            });
      },
    );
  }
}
