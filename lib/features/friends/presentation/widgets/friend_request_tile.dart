import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';

class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile({
    required this.request,
    super.key,
  });

  final FriendRequest request;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile placeholder
            const CircleAvatar(
              radius: 24,
              child: Icon(
                Icons.person,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Sender info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.senderName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sent on ${DateFormat('MMM d, yyyy').format(
                      request.sentAt.toLocal(),
                    )}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Accept / Reject
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Accept',
                  icon: const Icon(Icons.check_circle),
                  color: Colors.green,
                  onPressed: () {
                    context
                        .read<FriendsBloc>()
                        .add(AcceptFriendRequestEvent(request));
                  },
                ),
                IconButton(
                  tooltip: 'Reject',
                  icon: const Icon(Icons.cancel),
                  color: Colors.redAccent,
                  onPressed: () {
                    context
                        .read<FriendsBloc>()
                        .add(RejectFriendRequestEvent(request));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
