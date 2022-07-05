import 'package:chat_app/helper/user_model.dart';
import 'package:chat_app/provider/auth.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Messages extends StatefulWidget {
  final String senderId;
  final String senderName;
  final String senderImage;
  const Messages({
    Key? key,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
  }) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState(senderId, senderName);
}

class _MessagesState extends State<Messages> {
  late CollectionReference chats;
  String senderId;
  String senderName;
  final _controller = TextEditingController();

  _MessagesState(this.senderId, this.senderName);

  // final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  // final currentUserId = const AuthForm(isLoading: false).hashCode.toString();
  var chatDocId;

  @override
  void initState() {
    super.initState();
    chats = FirebaseFirestore.instance.collection('users');
    print('CHAT COLLECTION');
    print(chats.id);
    checkUser();
  }

  void checkUser() async {
    final currentUserId = Provider.of<Auth>(context, listen: false).userId;
    Provider.of<UserProvider>(context, listen: false).userID;

    await chats
        .where('userid', isEqualTo: {'1656656912267'})
        .snapshots()
        .single
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              /*setState(() {
                print("SnAPSHOT DOC ID ${querySnapshot.docs.single.id}");
                chatDocId = querySnapshot.docs.single.id;
              })*/

              print(chatDocId);

              print(UserModel().username);
            } else {
              print("ELSE USER");
              await chats.add({
                'users': {currentUserId: null, senderId: null},
                'username': {
                  // currentUserId: FirebaseAuth.instance.currentUser?.displayName,
                  currentUserId: currentUserId,
                  senderId: senderName
                }
              }).then((value) => {chatDocId = value});
            }
          },
        )
        .catchError((error) {
          print(error);
        });
  }

  Future<void> sendMessage(String message) async {
    // final user = FirebaseAuth.instance.currentUser;
    // final String userId = 'userId';
    // List<UserModel>? list = await Preference().getUserList();
    // var userId = list.any((user) => user.userId == UserModel().userId);
    final userId = Provider.of<Auth>(context, listen: false).userId;

    final userData =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (message == '') return;
    chats.doc(chatDocId).collection('messages').add({
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'username': userData['username'],
      'senderName': senderName,
      'message': message,
      'imageUrl': userData['image_url']
    }).then((value) {
      _controller.text = '';
    });
  }

  bool isOnline = false;

  bool isSender(String sender) {
    final currentUserId = Provider.of<Auth>(context).userId;
    print('USER ID    $currentUserId');

    return sender == currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    print('CHAT DOC ID $chatDocId');
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
                  title: StreamBuilder<DocumentSnapshot>(
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
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // leading: CircleAvatar(
                          //   backgroundImage: NetworkImage(widget.senderImage),
                          // ),
                          subtitle: Text(
                            snapshot.data!['status'],
                            style: TextStyle(
                              color: isOnline ? Colors.grey : Colors.teal,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  )),
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
                                          gradient: isSender(
                                                  data['userId'].toString())
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
                                          // color: isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(12),
                                            topRight: const Radius.circular(12),
                                            bottomLeft: !isSender(
                                                    data['userId'].toString())
                                                ? const Radius.circular(0)
                                                : const Radius.circular(12),
                                            bottomRight: isSender(
                                                    data['userId'].toString())
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
                                          crossAxisAlignment: isSender(
                                                  data['userId'].toString())
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (toBeginningOfSentenceCase(
                                                  data['username']
                                                      .toString())!),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSender(data['userId']
                                                        .toString())
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                            ),
                                            Text(
                                              (data['message'].toString()),
                                              style: TextStyle(
                                                color: isSender(data['userId']
                                                        .toString())
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                              textAlign: isSender(
                                                      data['userId'].toString())
                                                  ? TextAlign.end
                                                  : TextAlign.start,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data['createdAt'] == null
                                                  ? DateFormat.yMEd()
                                                      .add_jms()
                                                      .format(DateTime.now())
                                                      .toString()
                                                  : data['createdAt']
                                                      .toDate()
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: isSender(data['userId']
                                                          .toString())
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: isSender(data['userId'].toString())
                                      ? null
                                      : -10,
                                  right: isSender(data['userId'].toString())
                                      ? 180
                                      : null,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      (data['imageUrl'].toString()),
                                    ),
                                  ),
                                ),
                              ],
                            );
                            // return Container(
                            //   padding: const EdgeInsets.all(8),
                            //   child: ChatBubble(
                            //     clipper: ChatBubbleClipper6(
                            //       nipSize: 0,
                            //       radius: 0,
                            //       type: isSender(data['userId'].toString())
                            //           ? BubbleType.sendBubble
                            //           : BubbleType.receiverBubble,
                            //     ),
                            //     alignment:
                            //         getAlignment(data['userId'].toString()),
                            //     margin: const EdgeInsets.only(top: 20),
                            //     backGroundColor:
                            //         isSender(data['userId'].toString())
                            //             ? const Color(0xFF08C187)
                            //             : const Color(0xffE7E7ED),
                            //     child: Container(
                            //       constraints: BoxConstraints(
                            //         maxWidth:
                            //             MediaQuery.of(context).size.width * 0.7,
                            //       ),
                            //       child: Column(
                            //         children: [
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.start,
                            //             children: [
                            //               Text(data['message'],
                            //                   style: TextStyle(
                            //                       color: isSender(data['userId']
                            //                               .toString())
                            //                           ? Colors.white
                            //                           : Colors.black),
                            //                   maxLines: 100,
                            //                   overflow: TextOverflow.ellipsis)
                            //             ],
                            //           ),
                            //           Row(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.end,
                            //             children: [
                            //               Text(
                            //                 data['createdAt'] == null
                            //                     ? DateTime.now().toString()
                            //                     : data['createdAt']
                            //                         .toDate()
                            //                         .toString(),
                            //                 style: TextStyle(
                            //                     fontSize: 10,
                            //                     color: isSender(data['userId']
                            //                             .toString())
                            //                         ? Colors.white
                            //                         : Colors.black),
                            //               )
                            //             ],
                            //           )
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // );
                          }).toList(),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: _controller,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(
                                  labelText: 'Write your message'),
                            ),
                          ),
                          IconButton(
                            onPressed: () => sendMessage(_controller.text),
                            icon: const Icon(Icons.send),
                            color: Theme.of(context).primaryColor,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
            // return ListView.builder(
            //   itemBuilder: (ctx, index) {
            //     return MessageBubble(
            //       message: chatDocuments![index]['text'],
            //       userName: chatDocuments[index]['username'],
            //       userImage: chatDocuments[index]['userImage'],
            //       // userId: chatDocuments[index]['userId'],
            //       isMe: chatDocuments[index]['userId'] ==
            //           FirebaseAuth.instance.currentUser!.uid,
            //       key: ValueKey(chatDocuments[index].id),
            //     );
            //   },
            //   itemCount: chatSnapshot.data?.docs.length,
            // );
          }
          return Container();
        });
    // return FutureBuilder<void>(
    //   future: FirebaseAuth.instance.currentUser?.reload(),
    //   builder: (ctx, futureSnapshot) {
    //     if (futureSnapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }
    //     return StreamBuilder<QuerySnapshot>(
    //         stream: FirebaseFirestore.instance
    //             .collection('chat')
    //             // .doc(FirebaseAuth.instance.currentUser?.uid)
    //             // .collection('text')
    //             .orderBy('createdAt', descending: true)
    //             //.where("userId", isEqualTo: 'isPZ0MYpu8TFaOvBecXjak1f5b52')
    //             .snapshots(),
    //         builder: (ctx, chatSnapshot) {
    //           if (chatSnapshot.hasError) {
    //             print(chatSnapshot.hasError);
    //             print('_MessagesState.build');
    //             return const Center(
    //               child: Text('Something went Wrong'),
    //             );
    //           }
    //           if (chatSnapshot.connectionState == ConnectionState.waiting) {
    //             return const Center(
    //               child: CircularProgressIndicator(),
    //             );
    //           }
    //           final chatDocuments = chatSnapshot.data?.docs;
    //           return ListView.builder(
    //             reverse: true,
    //             itemBuilder: (ctx, index) {
    //               return MessageBubble(
    //                 message: chatDocuments![index]['text'],
    //                 userName: chatDocuments[index]['username'],
    //                 userImage: chatDocuments[index]['userImage'],
    //                 // userId: chatDocuments[index]['userId'],
    //                 isMe: chatDocuments[index]['userId'] ==
    //                     FirebaseAuth.instance.currentUser!.uid,
    //                 key: ValueKey(chatDocuments[index].id),
    //               );
    //             },
    //             itemCount: chatDocuments!.length,
    //           );
    //         });
    //   },
    // );
  }
}
