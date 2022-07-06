import 'package:chat_app/screen/chat_screen.dart';
import 'package:flutter/material.dart';

class UserBubble extends StatefulWidget {
  final String username;
  final String status;
  // final String imageUrl;
  final String senderId;
  const UserBubble({
    Key? key,
    required this.username,
    // required this.imageUrl,
    required this.status,
    required this.senderId,
  }) : super(key: key);

  @override
  State<UserBubble> createState() => _UserBubbleState();
}

class _UserBubbleState extends State<UserBubble> {
  void callChatScreen(
    String username,
    String userId,
    // String imageUrl,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        print('USER NAME IS : $username');
        print('SENDER ID IS: $userId');
        // print('IMAGE URL IS : $imageUrl');
        print('_UserBubbleState.callChatScreen');

        return ChatScreen(
          senderId: userId,
          username: username,
          // imageUrl: imageUrl,
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
        color: Colors.lightBlueAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          callChatScreen(
            widget.username,
            widget.senderId,
            // widget.imageUrl,
          );
          print('USER NAME IS: ${widget.username}');
          print('USER ID IS: ${widget.senderId}');
          // print(widget.imageUrl);
        },
        title: Text(widget.username),
        subtitle: Text(widget.status),
        leading: CircleAvatar(
            // backgroundImage: NetworkImage(widget.imageUrl),
            ),
      ),
    );
  }
}
