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
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.photoUrl != null
            ? NetworkImage(
                user.photoUrl!,
              )
            : null,
        child: user.photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(user.displayName ?? 'Unknown'),
      subtitle: Text(user.email ?? ''),
      trailing: ElevatedButton(
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
        child: const Text('Add Friend'),
      ),
    );
  }
}
