import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/profile_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';
import 'package:sync_together/features/auth/presentation/widgets/shimmer_party_list.dart';
import 'package:sync_together/features/auth/presentation/widgets/watch_party_tile.dart';
import 'package:sync_together/features/friends/presentation/views/friends_screen.dart';
import 'package:sync_together/features/platforms/presentation/views/platform_selection_screen.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/public_parties_cubit/public_parties_cubit.dart';
import 'package:sync_together/features/watch_party/presentation/views/room_lobby_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PublicPartiesCubit>().fetchPublicParties();
  }

  void _joinRoom(WatchParty party) {
    context.read<WatchPartySessionBloc>().add(
          JoinWatchPartyEvent(
            partyId: party.id,
            userId: context.currentUser!.uid,
          ),
        );

    Navigator.pushNamed(
      context,
      RoomLobbyScreen.id,
      arguments: party,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final name = context.currentUser?.displayName ?? 'Friend';
    return Scaffold(
      appBar: AppBar(
        title: Text('SyncTogether'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.id);
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              debugPrint('HomeScreen Current state: $state');
              if (state is AuthError) {
                CoreUtils.showSnackBar(context, state.message);
              }
              if (state is Unauthenticated) {
                debugPrint('Navigating back to login');
                context.userProvider.user = null;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  SplashScreen.id,
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
            listener: (context, state) {
              if (state is WatchPartyError) {
                CoreUtils.showSnackBar(
                  context,
                  state.message,
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildWelcomeBanner(name, colorScheme),
                const SizedBox(height: 35),
                _buildFriendsSummary(context),
                const SizedBox(height: 30),
                _buildQuickActions(name, colorScheme),
                const SizedBox(height: 30),
                _buildPublicPartiesSection(context),
              ],
            ),
          ),
        ),
      ),
    );
    // return MultiBlocListener(
    //   listeners: [
    //     BlocListener<AuthBloc, AuthState>(
    //       listener: (context, state) {
    //         debugPrint('HomeScreen Current state: $state');
    //         if (state is AuthError) {
    //           CoreUtils.showSnackBar(context, state.message);
    //         }
    //         if (state is Unauthenticated) {
    //           debugPrint('Navigating back to login');
    //           context.userProvider.user = null;
    //           Navigator.of(context).pushNamedAndRemoveUntil(
    //             SplashScreen.id,
    //             (route) => false,
    //           );
    //         }
    //       },
    //     ),
    //     BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
    //       listener: (context, state) {
    //         if (state is WatchPartyError) {
    //           CoreUtils.showSnackBar(
    //             context,
    //             state.message,
    //           );
    //         }
    //       },
    //     ),
    //   ],
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('SyncTogether'),
    //       actions: [
    //         IconButton(
    //           icon: const Icon(Icons.group),
    //           tooltip: 'Friends',
    //           onPressed: () {
    //             Navigator.pushNamed(context, FriendsScreen.id);
    //           },
    //         ),
    //         IconButton(
    //           icon: const Icon(Icons.person),
    //           tooltip: 'Profile Settings',
    //           onPressed: () {
    //             Navigator.pushNamed(context, ProfileScreen.id);
    //           },
    //         ),
    //         IconButton(
    //           icon: const Icon(Icons.logout),
    //           tooltip: 'Logout',
    //           onPressed: () {
    //             context.read<AuthBloc>().add(const SignOutEvent());
    //           },
    //         ),
    //       ],
    //     ),
    //     body: BlocBuilder<PublicPartiesCubit, WatchPartyListState>(
    //       builder: (context, state) {
    //         if (state is WatchPartyListLoading) {
    //           return const ShimmerPartyList();
    //         } else if (state is WatchPartyListLoaded) {
    //           if (state.parties.isEmpty) {
    //             return const Center(child: Text('No public watch parties.'));
    //           }
    //
    //           return LayoutBuilder(
    //             builder: (context, constraints) {
    //               final isWideScreen = constraints.maxWidth > 800;
    //               return isWideScreen
    //                   ? GridView.builder(
    //                       padding: const EdgeInsets.all(16),
    //                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                         crossAxisCount: 3,
    //                         mainAxisSpacing: 12,
    //                         crossAxisSpacing: 12,
    //                         childAspectRatio: 3,
    //                       ),
    //                       itemCount: state.parties.length,
    //                       itemBuilder: (context, index) => WatchPartyTile(
    //                         party: state.parties[index],
    //                         onPressed: () => _joinRoom(state.parties[index]),
    //                       ),
    //                     )
    //                   : ListView.separated(
    //                       shrinkWrap: true,
    //                       padding: const EdgeInsets.all(16),
    //                       itemCount: state.parties.length,
    //                       separatorBuilder: (_, __) => const SizedBox(
    //                         height: 12,
    //                       ),
    //                       itemBuilder: (context, index) => WatchPartyTile(
    //                         party: state.parties[index],
    //                         onPressed: () => _joinRoom(state.parties[index]),
    //                       ),
    //                     );
    //             },
    //           );
    //         } else if (state is WatchPartyListError) {
    //           return Center(
    //             child: Text(state.message),
    //           );
    //         }
    //         return const SizedBox();
    //       },
    //     ),
    //     floatingActionButton: FloatingActionButton.extended(
    //       onPressed: () {
    //         Navigator.pushNamed(
    //           context,
    //           PlatformSelectionScreen.id,
    //         );
    //       },
    //       label: const Text('Create Room'),
    //     ),
    //   ),
    // );
  }

  Widget _buildWelcomeBanner(String name, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '👋 Welcome back, $name!\nStart or join a party and stay connected.',
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickActions(String name, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _quickActionButton(
          icon: Icons.tv,
          label: 'Create Party',
          onTap: () {
            Navigator.pushNamed(context, PlatformSelectionScreen.id);
          },
        ),
        _quickActionButton(
          icon: Icons.person_add_alt_1,
          label: 'Add Friend',
          onTap: () {
            Navigator.pushNamed(context, FriendsScreen.id);
          },
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Null Function() onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surfaceContainerHighest;
    final iconColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsSummary(BuildContext context) {
    // For now, this is a placeholder. Later we can show online friends or count.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.group),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'View and manage your friends.',
              style: context.theme.textTheme.bodyLarge,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, FriendsScreen.id),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicPartiesSection(BuildContext context) {
    return BlocBuilder<PublicPartiesCubit, WatchPartyListState>(
      builder: (context, state) {
        if (state is WatchPartyListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is WatchPartyListError) {
          return Text(state.message, style: const TextStyle(color: Colors.red));
        } else if (state is WatchPartyListLoaded && state.parties.isEmpty) {
          return const Text('No public parties available at the moment.');
        } else if (state is WatchPartyListLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Public Watch Parties',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.parties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final party = state.parties[index];

                  // Dispatch to load host name (WatchPartyTile will read it)
                  context
                      .read<WatchPartySessionBloc>()
                      .add(GetUserByIdEvent(userId: party.hostId));

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: WatchPartyTile(
                      party: party,
                      onPressed: () => _joinRoom(party),
                    ),
                  );
                },
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
