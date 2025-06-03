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
    return MultiBlocListener(
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SyncTogether'),
          actions: [
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'Friends',
              onPressed: () {
                Navigator.pushNamed(context, FriendsScreen.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profile Settings',
              onPressed: () {
                Navigator.pushNamed(context, ProfileScreen.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthBloc>().add(const SignOutEvent());
              },
            ),
          ],
        ),
        body: BlocBuilder<PublicPartiesCubit, WatchPartyListState>(
          builder: (context, state) {
            if (state is WatchPartyListLoading) {
              return const ShimmerPartyList();
            } else if (state is WatchPartyListLoaded) {
              if (state.parties.isEmpty) {
                return const Center(child: Text('No public watch parties.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 800;
                  return isWideScreen
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3,
                          ),
                          itemCount: state.parties.length,
                          itemBuilder: (context, index) => WatchPartyTile(
                            party: state.parties[index],
                            onPressed: () => _joinRoom(state.parties[index]),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: state.parties.length,
                          separatorBuilder: (_, __) => const SizedBox(
                            height: 12,
                          ),
                          itemBuilder: (context, index) => WatchPartyTile(
                            party: state.parties[index],
                            onPressed: () => _joinRoom(state.parties[index]),
                          ),
                        );
                },
              );
            } else if (state is WatchPartyListError) {
              return Center(
                child: Text(state.message),
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(
              context,
              PlatformSelectionScreen.id,
            );
          },
          label: const Text('Create Room'),
        ),
      ),
    );
  }
}
