import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';

class RoomLobbyScreen extends StatelessWidget {
  const RoomLobbyScreen({required this.watchParty, super.key});

  final WatchParty watchParty;

  static const String id = '/room-lobby';

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is WatchPartyStarted) {
          Navigator.pushReplacementNamed(
            context,
            WatchPartyScreen.id,
            arguments: watchParty,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(watchParty.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (watchParty.hasStarted)
                const Text('Starting... Please wait')
              else if (context.currentUser!.uid == watchParty.hostId)
                ElevatedButton(
                  onPressed: () {
                    context.read<WatchPartyBloc>().add(
                      StartPartyEvent(watchParty.id),
                    );
                  },
                  child: const Text('Start Party'),
                )
              else
                const Text('Waiting for the host to start the party...'),
            ],
          ),
        ),
      ),
    );
  }
}
