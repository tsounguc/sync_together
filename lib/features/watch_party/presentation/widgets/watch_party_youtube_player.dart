import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/guest_sync_helper.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/sync_manager.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/youtube_playback_controller.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_status_badge.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class WatchPartyYoutubePlayer extends StatefulWidget {
  const WatchPartyYoutubePlayer({
    required this.watchParty,
    super.key,
  });

  final WatchParty watchParty;

  @override
  State<WatchPartyYoutubePlayer> createState() =>
      _WatchPartyYoutubePlayerState();
}

class _WatchPartyYoutubePlayerState extends State<WatchPartyYoutubePlayer> {
  late YoutubePlayerController _ytController;
  late YoutubePlaybackController playback;
  late final SyncManager syncManager;

  double? _latestPlaybackPosition;
  bool _latestIsPlaying = false;
  bool _hasSynced = false;
  bool _showChat = true;
  bool _showSyncBadge = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  Timer? _syncBadgeTimer;

  bool get _isHost => context.currentUser?.uid == widget.watchParty.hostId;

  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(
      widget.watchParty.videoUrl,
    );

    _ytController = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        // controlsVisibleAtStart: false,
        enableCaption: false,
      ),
    );

    playback = YoutubePlaybackController(_ytController);

    final bloc = context.read<WatchPartySessionBloc>();

    syncManager = SyncManager(
      playback: playback,
      watchPartyId: widget.watchParty.id,
      currentTimeScript: '',
      bloc: bloc,
    );

    if (_isHost) {
      syncManager.start();
    } else {
      bloc.add(GetSyncedDataEvent(partyId: widget.watchParty.id));
    }
    bloc.add(ListenToPartyExistenceEvent(widget.watchParty.id));

    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  void _updateSyncBadge(SyncStatus status) {
    if (_isHost || _syncStatus == status) return;
    if (mounted) {
      setState(() {
        _syncStatus = status;
        _showSyncBadge = true;
      });
    }

    _syncBadgeTimer?.cancel();
    if (status == SyncStatus.synced) {
      _syncBadgeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSyncBadge = false);
      });
    }
  }

  void _confirmEndParty() {
    final chatCubit = context.read<ChatCubit>();
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
              await syncManager.stop();
              await chatCubit.clearRoomTextMessages(
                roomId: widget.watchParty.id,
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
    return MultiBlocListener(
      listeners: [
        BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
          listener: _handleWatchPartyUpdates,
        ),
        BlocListener<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is MessagesCleared) {
              context.read<WatchPartySessionBloc>().add(
                    EndWatchPartyEvent(widget.watchParty.id),
                  );
            }
          },
        ),
      ],
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _ytController),
        builder: (context, player) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _isHost ? _confirmEndParty() : _leaveParty();
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 3000),
              curve: Curves.easeInOut,
              opacity: _opacity,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.watchParty.title),
                  centerTitle: true,
                  leading: _isHost
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'End Watch Party',
                          onPressed: _confirmEndParty,
                        )
                      : null,
                  actions: [
                    IconButton(
                      icon: Icon(
                          _showChat ? Icons.chat : Icons.chat_bubble_outline),
                      onPressed: () {
                        setState(() => _showChat = !_showChat);
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          player,
                          if (!_isHost && _showSyncBadge)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: SyncStatusBadge(status: _syncStatus),
                            ),
                        ],
                      ),
                    ),
                    if (_showChat)
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            border: Border(
                              top: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: WatchPartyChat(partyId: widget.watchParty.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleWatchPartyUpdates(
      BuildContext context, WatchPartySessionState state) async {
    if (state is SyncUpdated) {
      _latestPlaybackPosition = state.playbackPosition;
      if (!_isHost && _latestIsPlaying != state.isPlaying) {
        CoreUtils.showSnackBar(
          context,
          state.isPlaying
              ? 'The host started the video'
              : 'The host paused the video',
        );
      }

      _latestIsPlaying = state.isPlaying;

      if (!_isHost && !_hasSynced) {
        final synced = await GuestSyncHelper(
          playback: playback,
          targetPosition: _latestPlaybackPosition ?? 0,
          shouldPlay: _latestIsPlaying,
        ).attemptInitialSync();
        if (synced) _hasSynced = true;
      }

      final localPosition = await playback.getCurrentTime();
      final drift = (_latestPlaybackPosition! - localPosition).abs();

      _updateSyncBadge(drift < 3.0 ? SyncStatus.synced : SyncStatus.syncing);

      if (drift >= 1.5) await playback.seek(_latestPlaybackPosition!);

      final playing = await playback.isPlaying();
      if (state.isPlaying != playing) {
        state.isPlaying ? await playback.play() : await playback.pause();
      }
    }

    if (state is WatchPartyLeft) {
      await syncManager.stop();
      if (mounted) {
        await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    }

    if (state is WatchPartyEnded || state is WatchPartyEndedByHost) {
      CoreUtils.showSnackBar(context, 'The host ended the watch party');
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) {
        await Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    }
  }
}
