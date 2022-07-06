import 'package:chat_app/provider/user_provider.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Messages extends StatefulWidget {
  final String senderId;
  final String senderName;
  const Messages({
    Key? key,
    required this.senderId,
    required this.senderName,
  }) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState(senderId, senderName);
}

class _MessagesState extends State<Messages> {
  CollectionReference chats = FirebaseFirestore.instance.collection('chat');
  String senderId;
  String senderName;
  final _controller = TextEditingController();

  _MessagesState(this.senderId, this.senderName);
  var chatDocId;

  @override
  void initState() {
    super.initState();
    getAndAddUser();
  }

  void getAndAddUser() async {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;
    await chats
        .where('users', isEqualTo: {senderId: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });
            } else {
              await chats.add({
                'users': {currentUserId: null, senderId: null},
                'username': {
                  currentUserId:
                      Provider.of<UserProvider>(context, listen: false)
                          .user
                          ?.username,
                  senderId: senderName
                }
              }).then((value) => {
                    chatDocId = value,
                  });
            }
          },
        )
        .catchError((error) {
          print(error);
        });
  }

  Future<void> sendMessageButton(String message) async {
    final user = Provider.of<UserProvider>(context, listen: false).user?.userId;
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(user).get();
    if (message == '') return;
    chats.doc(chatDocId).collection('messages').add({
      'createdAt': FieldValue.serverTimestamp(),
      'userId': user,
      'username': userData['username'],
      'senderName': senderName,
      'message': message,
    }).then((value) {
      _controller.text = '';
    });
  }

  bool isOnline = true;

  bool isSender(String sender) {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.userId;

    return sender == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return getChatStreamBuilder(context);
  }

  Widget getChatStreamBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .doc(chatDocId)
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('SomeThing Went Wrong'),
            );
          }
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chatSnapshot.hasData) {
            final chatDocuments = chatSnapshot.data!.docs;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: appBarStreamBuilder(),
              ),
              body: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          reverse: true,
                          children:
                              chatDocuments.map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return messageBubble(data, context);
                          }).toList(),
                        ),
                      ),
                      newMessage(context)
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }

  Widget appBarStreamBuilder() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.data != null) {
          return ListTile(
            title: Text(
              toBeginningOfSentenceCase(senderName)!,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              snapshot.data!['status'],
              style: TextStyle(
                color: isOnline ? Colors.grey : Colors.teal,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget newMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextField(
            textCapitalization: TextCapitalization.sentences,
            controller: _controller,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            decoration: const InputDecoration(labelText: 'Write your message'),
          ),
        ),
        IconButton(
          onPressed: () => sendMessageButton(_controller.text),
          icon: const Icon(Icons.send),
          color: Theme.of(context).primaryColor,
        )
      ],
    );
  }

  Widget messageBubble(Map<String, dynamic> data, BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: isSender(data['userId'].toString())
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                // width: 150,
                decoration: BoxDecoration(
                  gradient: isSender(data['userId'].toString())
                      ? const LinearGradient(
                          colors: [
                            Color(0xff009688),
                            Color(0xff006259),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade300,
                            Colors.grey.shade300,
                          ],
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: !isSender(data['userId'].toString())
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                    bottomRight: isSender(data['userId'].toString())
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: isSender(data['userId'].toString())
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      (toBeginningOfSentenceCase(data['username'].toString())!),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSender(data['userId'].toString())
                              ? Colors.white
                              : Theme.of(context)
                                  .accentTextTheme
                                  .titleMedium
                                  ?.color),
                    ),
                    Text(
                      (data['message'].toString()),
                      style: TextStyle(
                        color: isSender(data['userId'].toString())
                            ? Colors.white
                            : Theme.of(context)
                                .accentTextTheme
                                .titleMedium
                                ?.color,
                      ),
                      textAlign: isSender(data['userId'].toString())
                          ? TextAlign.end
                          : TextAlign.start,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      data['createdAt'] == null
                          ? DateFormat().toString()
                          : DateFormat.yMd().add_jm().format(DateTime.parse(
                              data['createdAt'].toDate().toString())),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSender(data['userId'].toString())
                              ? Colors.white
                              : Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
