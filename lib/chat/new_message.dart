import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({Key? key}) : super(key: key);

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _controller = TextEditingController();
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      final user = FirebaseAuth.instance.currentUser;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      FirebaseFirestore.instance.collection('chat').add({
        'text': _controller.text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user?.uid,
        'username': userData['username'],
        'userImage': userData['image_url'],
      }).then((value) => _controller.text = '');
      _controller.clear();
    }
    // setState(() {
    //   _controller.text = '';
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              controller: _controller,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.send,
              decoration:
                  const InputDecoration(labelText: 'Write your message'),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    );
  }
}
