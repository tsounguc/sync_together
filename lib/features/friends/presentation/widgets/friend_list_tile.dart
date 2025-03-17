import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/presentation/friend_bloc/friend_bloc.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    required this.friend,
    super.key,
  });

  final Friend friend;

  void _removeFriend(BuildContext context) {
    context.read<FriendBloc>().add(
          RemoveFriendEvent(
            senderId: friend.user1Id,
            receiverId: friend.user2Id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(
        context.currentUser?.displayName == friend.user1Name ? friend.user2Name : friend.user1Name,
      ),
      subtitle: const Text('Friend since...'),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle, color: Colors.red),
        onPressed: () => _removeFriend(context),
      ),
    );
  }
}
