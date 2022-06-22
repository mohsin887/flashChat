import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  // final String userId;
  final String userName;
  final String userImage;
  const MessageBubble({
    Key? key,
    required this.message,
    this.isMe = false,
    required this.userName,
    required this.userImage,
    // required this.userId,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                gradient: widget.isMe
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
                  bottomLeft: !widget.isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                  bottomRight: widget.isMe
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
                crossAxisAlignment: widget.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isMe
                            ? Colors.white
                            : Theme.of(context)
                                .accentTextTheme
                                .titleMedium
                                ?.color),
                  ),
                  Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.isMe
                          ? Colors.white
                          : Theme.of(context)
                              .accentTextTheme
                              .titleMedium
                              ?.color,
                    ),
                    textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: widget.isMe ? null : 130,
          right: widget.isMe ? 130 : null,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.userImage),
          ),
        ),
      ],
    );
  }
}
