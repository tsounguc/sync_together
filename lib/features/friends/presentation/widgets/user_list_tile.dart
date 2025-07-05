import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/data/models/friend_request_model.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({
    required this.user,
    super.key,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Unknown',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Add friend button
            ElevatedButton(
              onPressed: () {
                context.read<FriendsBloc>().add(
                      SendFriendRequestEvent(
                        FriendRequestModel.empty().copyWith(
                          senderId: context.currentUser!.uid,
                          senderName: context.currentUser!.displayName,
                          receiverId: user.uid,
                          receiverName: user.displayName,
                        ),
                      ),
                    );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
