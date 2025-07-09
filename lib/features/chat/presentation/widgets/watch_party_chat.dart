import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';
import 'package:sync_together/features/chat/presentation/widgets/message_bubble.dart';

class WatchPartyChat extends StatefulWidget {
  const WatchPartyChat({
    required this.partyId,
    super.key,
  });

  final String partyId;

  @override
  State<WatchPartyChat> createState() => _WatchPartyChatState();
}

class _WatchPartyChatState extends State<WatchPartyChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _typingUserNames = [];
  Timer? _typingDebounce;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.currentUser!;
    context.read<ChatCubit>().sendTextMessage(
          roomId: widget.partyId,
          message: Message(
            id: UniqueKey().toString(),
            senderId: currentUser.uid,
            senderName: currentUser.displayName!,
            text: text,
            timestamp: DateTime.now(),
          ),
        );
    _controller.clear();

    // Stop typing
    context.read<ChatCubit>().updateTypingStatus(
          roomId: widget.partyId,
          userId: currentUser.uid,
          userName: currentUser.displayName!,
          isTyping: false,
        );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().listenToMessagesStream(widget.partyId);
    context.read<ChatCubit>().listenToTypingUsersStream(widget.partyId);
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
<<<<<<< HEAD
=======

    final user = context.currentUser;
    if (user != null) {
      context.read<ChatCubit>().updateTypingStatus(
            roomId: widget.partyId,
            userId: user.uid,
            userName: user.displayName!,
            isTyping: false,
          );
    }

>>>>>>> 582330700bf4dc0f3efb4f41c7d18ca0f147c0de
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {},
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (prev, curr) => curr is! TypingUsersUpdated,
              builder: (context, state) {
                if (state is MessagesReceived) {
                  _scrollToBottom();
                  final messages = state.messages;

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == context.currentUser?.uid;
                      final isSameSender = index == 0 ||
                          messages[index - 1].senderId != message.senderId;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: isMe
                              ? () => _showMessageOptions(context, message)
                              : null,
                          child: MessageBubble(
                            isMe: isMe,
                            isSamePerson: isSameSender,
                            message: message,
                          ),
                        ),
                      );
                    },
                  );
                }

                if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (previous, current) => current is TypingUsersUpdated,
            builder: (context, state) {
              if (state is TypingUsersUpdated) {
                final currentUser = context.currentUser?.displayName;
                final otherTyping = state.userNames
                    .where((name) => name != currentUser)
                    .toList();
                if (otherTyping.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${otherTyping.join(', ')} is typing...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ).copyWith(bottom: 8, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: IField(
                    controller: _controller,
                    onFieldSubmitted: (_) => _sendMessage(),
                    hintText: 'Type your message...',
                    borderRadius: BorderRadius.circular(10),
                    textInputAction: TextInputAction.send,
                    onChanged: (value) {
                      final user = context.currentUser!;
                      final cubit = context.read<ChatCubit>()
                        ..updateTypingStatus(
                          roomId: widget.partyId,
                          userId: user.uid,
                          userName: user.displayName!,
                          isTyping: true,
                        );

                      _typingDebounce?.cancel();
                      _typingDebounce = Timer(const Duration(seconds: 2), () {
                        cubit.updateTypingStatus(
                          roomId: widget.partyId,
                          userId: user.uid,
                          userName: user.displayName!,
                          isTyping: false,
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, Message message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatCubit>().deleteTextMessage(
                        roomId: widget.partyId,
                        messageId: message.id,
                      );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.text));
                  CoreUtils.showSnackBar(context, 'Message copied');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
