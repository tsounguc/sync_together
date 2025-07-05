import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    required this.friend,
    super.key,
  });

  final Friend friend;

  void _removeFriend(BuildContext context) {
    context.read<FriendsBloc>().add(
          RemoveFriendEvent(
            senderId: friend.user1Id,
            receiverId: friend.user2Id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUser1 = context.currentUser?.uid == friend.user1Id;
    final friendName = isUser1 ? friend.user2Name : friend.user1Name;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person, size: 24),
            ),
            const SizedBox(width: 16),

            // Friend name and "since" text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Friends since ${DateFormat('MMM d, yyyy').format(
                      friend.createdAt.toLocal(),
                    )}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Remove icon
            IconButton(
              icon: const Icon(Icons.remove_circle),
              color: Colors.redAccent,
              tooltip: 'Remove Friend',
              onPressed: () => _removeFriend(context),
            ),
          ],
        ),
      ),
    );
  }
}
