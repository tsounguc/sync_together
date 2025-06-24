import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/platform_video_picker_screen.dart';
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
    context.read<WatchPartySessionBloc>()
      ..add(ListenToPartyStartEvent(widget.watchParty.id))
      ..add(ListenToParticipantsEvent(widget.watchParty.id));
  }

  void _startParty() {
    final isDRMProtected = widget.watchParty.platform.isDRMProtected;
    final hasVideoUrl = widget.watchParty.videoUrl.isNotEmpty;

    if (!isDRMProtected && !hasVideoUrl) {
      CoreUtils.showSnackBar(
        context,
        'Please select a video before starting the party.',
      );
      return;
    }

    context.read<WatchPartySessionBloc>().add(
          StartPartyEvent(widget.watchParty.id),
        );
  }

  void _goToWatchParty() {
    Navigator.pushReplacementNamed(
      context,
      WatchPartyScreen.id,
      arguments: WatchPartyScreenArguments(
        widget.watchParty,
        widget.watchParty.platform,
      ),
    );
  }

  void _goToPickVideo() {
    Navigator.pushNamed(
      context,
      PlatformVideoPickerScreen.id,
      arguments: PlatformVideoPickerScreenArgument(
        watchParty: widget.watchParty,
        platform: widget.watchParty.platform,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) {
        if (state is WatchPartyStarted && context.currentUser!.uid == widget.watchParty.hostId) {
          _goToWatchParty();
        }

        if (state is PartyStartedRealtime) {
          _goToWatchParty();
        }
        if (state is WatchPartyError) {
          CoreUtils.showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.watchParty.title),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final isHost = context.currentUser!.uid == widget.watchParty.hostId;
            final isDRMProtected = widget.watchParty.platform.isDRMProtected;
            final hasVideoUrl = widget.watchParty.videoUrl.isNotEmpty;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Room Lobby',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Platform: ${widget.watchParty.platform.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  // Host: Start Party + Pick Video button
                  if (isHost) ...[
                    ElevatedButton.icon(
                      onPressed: _startParty,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Party'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(isWide ? 300 : double.infinity, 50),
                      ),
                    ),
                    if (!isDRMProtected && !hasVideoUrl)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: OutlinedButton.icon(
                          onPressed: _goToPickVideo,
                          icon: const Icon(Icons.search),
                          label: const Text('Pick Video'),
                        ),
                      ),
                  ]
                  // Guest: waiting state
                  else ...[
                    const Text(
                      'Waiting for host to start the party...',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator.adaptive(),
                  ],
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Participants',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: BlocBuilder<WatchPartySessionBloc, WatchPartySessionState>(
                              builder: (context, state) {
                                if (state is ParticipantsProfilesUpdated) {
                                  final participants = state.profiles;
                                  if (participants.isEmpty) {
                                    return const Center(
                                      child: Text('No Participants yet.'),
                                    );
                                  }

                                  return ListView.separated(
                                    itemCount: participants.length,
                                    itemBuilder: (context, index) {
                                      final user = participants[index];
                                      final isYou = user.uid == context.currentUser!.uid;
                                      return Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 16,
                                            child: Icon(Icons.person, size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              isYou
                                                  ? '${user.displayName} (You)'
                                                  : user.displayName ?? 'Anonymous',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (_, __) => const Divider(
                                      height: 16,
                                    ),
                                  );
                                }

                                return const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
