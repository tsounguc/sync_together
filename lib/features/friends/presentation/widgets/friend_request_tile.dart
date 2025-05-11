import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';

/// **FriendRequestTile**
///
/// This widget displays a **pending friend request** with **Accept** and **Reject** buttons.
class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile({required this.request, super.key});

  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text('Request from: ${request.senderName}'), // Placeholder for username
        subtitle: Text('Sent on: ${DateFormat('MMM d, yyyy').format(
          request.sentAt.toLocal(),
        )}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              tooltip: 'Accept Request',
              onPressed: () {
                context.read<FriendsBloc>().add(
                      AcceptFriendRequestEvent(request),
                    );
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'Reject Request',
              onPressed: () {
                context.read<FriendsBloc>().add(
                      RejectFriendRequestEvent(request),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
