import 'package:flutter/material.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.isMe,
    required this.isSamePerson,
    required this.message,
    super.key,
  });

  final bool isMe;
  final bool isSamePerson;
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSamePerson)
          const SizedBox(
            height: 30,
          ),
        if (!isMe && isSamePerson)
          Padding(
            padding: const EdgeInsets.only(
              bottom: 2,
              left: 15,
            ),
            child: Text(
              message.senderName,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.grey.shade200,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: context.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isMe ? Colors.blueAccent : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
