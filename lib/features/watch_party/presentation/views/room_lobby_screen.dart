import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class RoomLobbyScreen extends StatefulWidget {
  const RoomLobbyScreen({required this.watchParty, super.key});

  final WatchParty watchParty;

  static const String id = '/room-lobby';

  @override
  State<RoomLobbyScreen> createState() => _RoomLobbyScreenState();
}

class _RoomLobbyScreenState extends State<RoomLobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to live playback sync updates
    context.read<WatchPartySessionBloc>().add(
          ListenToPartyStartEvent(
            widget.watchParty.id,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) {
        if (state is WatchPartyFetched) {
          Navigator.pushReplacementNamed(
            context,
            WatchPartyScreen.id,
            arguments: WatchPartyScreenArguments(
              state.watchParty,
              state.watchParty.platform,
            ),
          );
        }
        if (state is WatchPartyStarted && context.currentUser!.uid == widget.watchParty.hostId) {
          context.read<WatchPartySessionBloc>().add(
                GetWatchPartyEvent(widget.watchParty.id),
              );
        }

        if (state is PartyStartedRealtime) {
          context.read<WatchPartySessionBloc>().add(
                GetWatchPartyEvent(widget.watchParty.id),
              );
          // Navigator.pop(context);
          // Navigator.pushNamed(
          //   context,
          //   WatchPartyScreen.id,
          //   arguments: WatchPartyScreenArguments(
          //     widget.watchParty,
          //     widget.watchParty.platform,
          //   ),
          // );
        } else if (state is WatchPartyError) {
          CoreUtils.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.watchParty.title),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // If you are the host
              if (context.currentUser!.uid == widget.watchParty.hostId)
                ElevatedButton(
                  onPressed: () {
                    context.read<WatchPartySessionBloc>().add(
                          StartPartyEvent(widget.watchParty.id),
                        );
                  },
                  child: const Text('Start Party'),
                )
              // If you are a guest
              else
                const Text('Waiting for the host to start the party...'),
              const SizedBox(height: 20),
              // Extra feedback for everyone
              const CircularProgressIndicator.adaptive(), // subtle spinner while waiting
              const SizedBox(height: 8),
              const Text('Waiting for party to start...'),
            ],
          ),
        ),
      ),
    );
  }
}
