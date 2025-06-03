import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    required this.partyId,
    super.key,
  });

  final String partyId;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendTextMessage(
          roomId: widget.partyId,
          message: Message(
            id: UniqueKey().toString(),
            senderId: context.currentUser!.uid,
            senderName: context.currentUser!.displayName!,
            text: text,
            timestamp: DateTime.now(),
          ),
        );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _send,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }
}
