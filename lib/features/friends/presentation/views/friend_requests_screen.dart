import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/presentation/friend_bloc/friend_bloc.dart';
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
      context.read<FriendBloc>().add(GetFriendRequestsEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          debugPrint('FriendRequestScreen: $state');
          if (state is FriendLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FriendRequestsLoaded) {
            final requests = state.requests;
            if (requests.isEmpty) {
              return const Center(child: Text('No incoming friend requests.'));
            }
            return ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return FriendRequestTile(request: request);
              },
            );
          } else if (state is FriendError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }
}
