import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_list_cubit/watch_party_list_cubit.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  static const String id = '/join-room';

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  WatchParty? _selectedParty;

  @override
  void initState() {
    super.initState();
    context.read<WatchPartyListCubit>().fetchPublicParties();
  }

  void _joinRoom(WatchParty party) {
    setState(() {
      _selectedParty = party;
    });

    context.read<WatchPartyBloc>().add(
          JoinWatchPartyEvent(
            partyId: party.id,
            userId: context.currentUser!.uid,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is WatchPartyJoined) {
          if (_selectedParty != null) {
            Navigator.pushNamed(
              context,
              WatchPartyScreen.id,
              arguments: _selectedParty,
            );
          }
        } else if (state is WatchPartyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Join a Room')),
        body: BlocBuilder<WatchPartyListCubit, WatchPartyListState>(
          builder: (context, state) {
            if (state is WatchPartyListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WatchPartyListError) {
              return Center(child: Text(state.message));
            } else if (state is WatchPartyListLoaded) {
              final parties = state.parties;
              if (parties.isEmpty) {
                return const Center(child: Text('No public rooms available.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: parties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final party = parties[index];
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
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
