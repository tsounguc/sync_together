import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class SyncControlsBar extends StatelessWidget {
  const SyncControlsBar({
    required this.partyId,
    required this.isHost,
    super.key,
  });

  final String partyId;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) {
        if (state is SyncUpdated) {
          CoreUtils.showSnackBar(context, 'Sync updated: ${state.playbackPosition}s');
        }
      },
      child: Row(
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            onPressed: isHost
                ? () {
                    context.read<WatchPartySessionBloc>().add(
                          SendSyncDataEvent(
                            partyId: partyId,
                            playbackPosition: 0, // Estimate or prompt input
                            isPlaying: true,
                          ),
                        );
                  }
                : null,
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.pause),
            label: const Text("Pause"),
            onPressed: isHost
                ? () {
                    context.read<WatchPartySessionBloc>().add(
                          SendSyncDataEvent(
                            partyId: partyId,
                            playbackPosition: 0, // Estimate or prompt input
                            isPlaying: false,
                          ),
                        );
                  }
                : null,
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: const Text('Sync'),
            onPressed: () {
              context.read<WatchPartySessionBloc>().add(GetSyncedDataEvent(partyId: partyId));
            },
          ),
        ],
      ),
    );
  }
}
