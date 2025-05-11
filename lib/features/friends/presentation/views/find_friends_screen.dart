import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';
import 'package:sync_together/features/friends/presentation/widgets/user_list_tile.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  static const String id = '/find-friends';

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final _searchController = TextEditingController();

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    context.read<FriendsBloc>().add(SearchUsersEvent(query: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search users...',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (context, state) {
                  if (state is FriendsLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoaded) {
                    return ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        return UserListTile(user: state.users[index]);
                      },
                    );
                  } else if (state is FriendsError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('Search for users.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
