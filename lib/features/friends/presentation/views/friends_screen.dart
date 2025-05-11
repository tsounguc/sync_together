import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';
import 'package:sync_together/features/friends/presentation/views/find_friends_screen.dart';
import 'package:sync_together/features/friends/presentation/views/friend_requests_screen.dart';
import 'package:sync_together/features/friends/presentation/widgets/friend_list_tile.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  static const String id = '/friends';

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late String? userId;
  @override
  void initState() {
    super.initState();
    userId = context.currentUser?.uid;
    if (userId != null) {
      context.read<FriendsBloc>().add(GetFriendsEvent(userId: userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Column(
        children: [
          // 📌 Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Friend Requests'),
                  onPressed: () {
                    Navigator.pushNamed(context, FriendRequestsScreen.id);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Find Friends'),
                  onPressed: () {
                    Navigator.pushNamed(context, FindFriendsScreen.id);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                  ),
                ),
              ],
            ),
          ),

          // 📌 Friends List
          Expanded(
            child: BlocConsumer<FriendsBloc, FriendsState>(
              listener: (context, state) {
                if (state is FriendRemoved) {
                  context.read<FriendsBloc>().add(
                        GetFriendsEvent(userId: userId!),
                      );
                }
              },
              builder: (context, state) {
                debugPrint('FriendState: $state');
                if (state is FriendsLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FriendsLoaded) {
                  final friends = state.friends;
                  if (friends.isEmpty) {
                    return const Center(child: Text('No friends yet.'));
                  }
                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return FriendListTile(friend: friend);
                    },
                  );
                } else if (state is FriendsError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: Text('Loading...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
