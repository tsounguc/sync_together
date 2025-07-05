import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
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
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(title: const Text('Find Friends')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor,
                border: theme.inputDecorationTheme.border,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔽 Search Results
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (context, state) {
                  if (state is FriendsLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users found.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: state.users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return UserListTile(user: state.users[index]);
                      },
                    );
                  } else if (state is FriendsError) {
                    return Center(
                      child: Text(
                        '⚠️ ${state.message}',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.red),
                      ),
                    );
                  }

                  return const Center(
                    child: Text(
                      'Search for users above.',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
