import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/profile_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';
import 'package:sync_together/features/friends/presentation/views/friends_screen.dart';
import 'package:sync_together/features/platforms/presentation/views/platform_selection_screen.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/room_lobby_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_list_cubit/watch_party_list_cubit.dart';

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
    context.read<WatchPartyListCubit>().fetchPublicParties();
  }

  void _joinRoom(WatchParty party) {
    context.read<WatchPartyBloc>().add(
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
        BlocListener<WatchPartyBloc, WatchPartyState>(
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
        body: BlocBuilder<WatchPartyListCubit, WatchPartyListState>(
          builder: (context, state) {
            if (state is WatchPartyListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is WatchPartyListLoaded) {
              if (state.parties.isEmpty) {
                return const Center(child: Text('No public watch parties.'));
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: state.parties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final party = state.parties[index];
                  return ListTile(
                    tileColor: Colors.grey[900],
                    leading: Image.asset(
                      party.platform.logoPath,
                      width: 40,
                      height: 40,
                    ),
                    title: Text(party.title),
                    subtitle: Text(
                      '${party.platform.name} • ${party.participantIds.length} joined',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _joinRoom(party),
                      child: const Text('Join'),
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

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   static const String id = '/home';
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   WatchParty? _selectedParty;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<WatchPartyListCubit>().fetchPublicParties();
//   }
//
//   void _joinRoom(WatchParty party) {
//     setState(() {
//       _selectedParty = party;
//     });
//
//     context.read<WatchPartyBloc>().add(
//       JoinWatchPartyEvent(
//         partyId: party.id,
//         userId: context.currentUser!.uid,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthBloc, AuthState>(
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
//                 (route) => false,
//           );
//         }
//       },
//       builder: (context, state) {
//         // final user = context.userProvider.user;
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('SyncTogether'),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.group),
//                 tooltip: 'Friends',
//                 onPressed: () {
//                   Navigator.pushNamed(context, FriendsScreen.id);
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.person),
//                 tooltip: 'Profile Settings',
//                 onPressed: () {
//                   Navigator.pushNamed(context, ProfileScreen.id);
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.logout),
//                 tooltip: 'Logout',
//                 onPressed: () {
//                   context.read<AuthBloc>().add(const SignOutEvent());
//                 },
//               ),
//             ],
//           ),
//           body: BlocBuilder(builder: (context, state) {
//             if (state is WatchPartyListLoading) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (state is WatchPartyListLoaded) {
//               if (state.parties.isEmpty) {
//                 return const Center(child: Text('No public watch parties.'));
//               }
//               return ListView.separated(
//                 shrinkWrap: true,
//                 padding: const EdgeInsets.all(16),
//                 itemCount: state.parties.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 12),
//                 itemBuilder: (context, index) {
//                   final party = state.parties[index];
//                   return ListTile(
//                     tileColor: Colors.grey[900],
//                     leading: Image.asset(
//                       party.platform.logoPath,
//                       width: 40,
//                       height: 40,
//                     ),
//                     title: Text(party.title),
//                     subtitle: Text(
//                       '${party.platform.name} • ${party.participantIds.length} joined',
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: () => _joinRoom(party),
//                       child: const Text('Join'),
//                     ),
//                   );
//                 },
//               );
//             } else if (state is WatchPartyListError) {
//               return Center(
//                 child: Text(state.message),
//               );
//             }
//             return const SizedBox();
//           }),
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: () {
//               Navigator.pushNamed(
//                 context,
//                 PlatformSelectionScreen.id,
//               );
//             },
//             label: const Text('Create Room'),
//           ),
//         );
//       },
//     );
//   }
// }
