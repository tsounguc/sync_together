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
    _loadFriends();
  }

  void _loadFriends() {
    userId = context.currentUser?.uid;
    if (userId != null) {
      context.read<FriendsBloc>().add(GetFriendsEvent(userId: userId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 📌 Navigation Buttons
            _buildActionButtons(context),
            SizedBox(height: 25),
            // 📌 Friends List
            Expanded(child: _buildFriendsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Friend Requests'),
            onPressed: () {
              Navigator.pushNamed(context, FriendRequestsScreen.id);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Find Friends'),
            onPressed: () {
              Navigator.pushNamed(context, FindFriendsScreen.id);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList(BuildContext context) {
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is FriendRemoved && userId != null) {
          _loadFriends();
        }
      },
      builder: (context, state) {
        if (state is FriendsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FriendsError) {
          return Center(
            child: Text(
              '⚠️ ${state.message}',
              style: context.theme.textTheme.bodyLarge
                  ?.copyWith(color: Colors.red),
            ),
          );
        } else if (state is FriendsLoaded) {
          final friends = state.friends;
          if (friends.isEmpty) {
            return const Center(
                child: Text('You haven’t added any friends yet.'));
          }

          return ListView.separated(
            itemCount: friends.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return FriendListTile(friend: friend);
            },
          );
        }

        return const Center(child: Text('Loading...'));
      },
    );
  }
}
