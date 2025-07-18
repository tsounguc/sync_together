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
  bool get _isHost => context.currentUser?.uid == widget.watchParty.hostId;

  @override
  void initState() {
    super.initState();
    context.read<WatchPartySessionBloc>()
      ..add(ListenToPartyStartEvent(widget.watchParty.id))
      ..add(ListenToParticipantsEvent(widget.watchParty.id))
      ..add(ListenToPartyExistenceEvent(widget.watchParty.id));
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

    context
        .read<WatchPartySessionBloc>()
        .add(StartPartyEvent(widget.watchParty.id));
  }

  void _goToWatchParty({WatchParty? party}) {
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        WatchPartyScreen.id,
        arguments: WatchPartyScreenArguments(
          party ?? widget.watchParty,
          widget.watchParty.platform,
        ),
      );
    }
  }

  Future<void> _goToPickVideo() async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(
      PlatformVideoPickerScreen.id,
      arguments: PlatformVideoPickerScreenArgument(
        watchParty: widget.watchParty,
        platform: widget.watchParty.platform,
      ),
    );
  }

  void _confirmEndParty() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Watch Party?'),
        content: const Text('This will disconnect all guests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              context.read<WatchPartySessionBloc>().add(
                    EndWatchPartyEvent(widget.watchParty.id),
                  );
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  void _leaveParty() {
    context.read<WatchPartySessionBloc>().add(
          LeaveWatchPartyEvent(
            partyId: widget.watchParty.id,
            userId: context.currentUser?.uid ?? '',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isHost = context.currentUser!.uid == widget.watchParty.hostId;
    final isDRMProtected = widget.watchParty.platform.isDRMProtected;
    final hasVideoUrl = widget.watchParty.videoUrl.isNotEmpty;

    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) async {
        if (state is WatchPartyStarted && isHost) {
          await Future<void>.delayed(const Duration(seconds: 2));
          _goToWatchParty();
        } else if (state is WatchPartyFetched) {
          _goToWatchParty(party: state.watchParty);
        } else if (state is PartyStartedRealtime) {
          context
              .read<WatchPartySessionBloc>()
              .add(GetWatchPartyEvent(widget.watchParty.id));
        }
        if (state is WatchPartyLeft) {
          if (mounted) {
            await Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          }
        }
        if (state is WatchPartyEnded || state is WatchPartyEndedByHost) {
          if (mounted) {
            CoreUtils.showSnackBar(context, 'The host ended the watch party');

            await Future<void>.delayed(const Duration(seconds: 2));
            if (mounted) {
              await Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            }
          }
        }
        if (state is WatchPartyError) {
          CoreUtils.showSnackBar(context, state.message);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _isHost ? _confirmEndParty() : _leaveParty();
        },
        child: Scaffold(
          appBar: AppBar(title: Text(widget.watchParty.title)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Room Lobby', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Image.asset(
                        context.themeMode == ThemeMode.dark &&
                                !widget.watchParty.platform.logoPath
                                    .contains('disney')
                            ? widget.watchParty.platform.logoDarkPath
                            : widget.watchParty.platform.logoPath,
                        width: 40,
                      ),
                      title: Text(widget.watchParty.platform.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: hasVideoUrl
                          ? Text('Video selected ✅',
                              style: theme.textTheme.bodySmall)
                          : Text('No video selected',
                              style: theme.textTheme.bodySmall),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isHost) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Party'),
                        onPressed: _startParty,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    if (!isDRMProtected && !hasVideoUrl) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.video_library),
                          label: const Text('Pick Video'),
                          onPressed: _goToPickVideo,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    const Text(
                      'Waiting for host to start the party...',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ],
                  const SizedBox(height: 32),

                  // 👥 Participants Section
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Participants',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 12),
                            Expanded(
                              child: BlocBuilder<WatchPartySessionBloc,
                                  WatchPartySessionState>(
                                builder: (context, state) {
                                  if (state is ParticipantsProfilesUpdated) {
                                    final participants = state.profiles;
                                    if (participants.isEmpty) {
                                      return const Center(
                                          child: Text('No participants yet.'));
                                    }

                                    return ListView.separated(
                                      itemCount: participants.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 16),
                                      itemBuilder: (context, index) {
                                        final user = participants[index];
                                        final isYou = user.uid ==
                                            context.currentUser!.uid;
                                        return Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 18,
                                              child:
                                                  Icon(Icons.person, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                isYou
                                                    ? '${user.displayName} (You)'
                                                    : user.displayName ??
                                                        'Anonymous',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  return const Center(
                                      child:
                                          CircularProgressIndicator.adaptive());
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
