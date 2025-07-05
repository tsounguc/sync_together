import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';
import 'package:sync_together/features/friends/presentation/widgets/friend_request_tile.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  static const String id = '/friend-requests';

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.currentUser?.uid;
    if (userId != null) {
      context.read<FriendsBloc>().add(GetFriendRequestsEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<FriendsBloc, FriendsState>(
          builder: (context, state) {
            if (state is FriendsLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FriendRequestsLoaded) {
              final requests = state.requests;

              if (requests.isEmpty) {
                return const Center(
                  child: Text(
                    'No incoming friend requests.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return FriendRequestTile(request: request);
                },
              );
            } else if (state is FriendsError) {
              return Center(
                child: Text(
                  '⚠️ ${state.message}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                ),
              );
            }

            return const Center(child: Text('Loading...'));
          },
        ),
      ),
    );
  }
}
