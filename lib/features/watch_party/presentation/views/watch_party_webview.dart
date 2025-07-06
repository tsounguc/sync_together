import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/core/utils/video_url_helper.dart';
import 'package:sync_together/core/utils/webview_loader.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/guest_sync_helper.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controller.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/sync_manager.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_status_badge.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/web_playback_controls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WatchPartyWebView extends StatefulWidget {
  const WatchPartyWebView({super.key, required this.watchParty});

  final WatchParty watchParty;

  @override
  State<WatchPartyWebView> createState() => _WatchPartyWebViewState();
}

class _WatchPartyWebViewState extends State<WatchPartyWebView> {
  WebViewController? _webViewController;
  late final PlaybackController playback;
  late final SyncManager syncManager;
  late final StreamingPlatform streamingPlatform;

  bool get _isHost => context.currentUser?.uid == widget.watchParty.hostId;

  int loadingPercentage = 0;
  bool _showChat = true;
  bool _showSyncBadge = true;
  SyncStatus _syncStatus = SyncStatus.synced;
  Timer? _syncBadgeTimer;

  double? _latestPlaybackPosition;
  bool _latestIsPlaying = false;
  bool _hasSynced = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  @override
  void dispose() {
    syncManager.stop();
    _syncBadgeTimer?.cancel();
    _webViewController = null;
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    streamingPlatform = widget.watchParty.platform;
    final bloc = context.read<WatchPartySessionBloc>();
    final rawUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl;

    final embedUrl = VideoUrlHelper.getEmbedUrl(rawUrl, streamingPlatform.name);
    final controller = await WebviewLoader.create(
      embedUrl: embedUrl,
      navigationDelegate: _navigationDelegate,
    );

    playback = PlaybackController(
      controller: controller,
      platform: streamingPlatform,
    );
    syncManager = SyncManager(
      playback: playback,
      watchPartyId: widget.watchParty.id,
      currentTimeScript: streamingPlatform.currentTimeScript,
      bloc: bloc,
    );

    if (!mounted) return;
    setState(() => _webViewController = controller);

    if (_isHost) {
      syncManager.start();
    } else {
      bloc.add(GetSyncedDataEvent(partyId: widget.watchParty.id));
    }

    bloc.add(ListenToPartyExistenceEvent(widget.watchParty.id));
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) => setState(() => loadingPercentage = progress),
        onPageStarted: (_) => setState(() => loadingPercentage = 0),
        onPageFinished: (_) async {
          setState(() => loadingPercentage = 100);
          if (!_isHost && !_hasSynced) {
            final synced = await GuestSyncHelper(
              playback: playback,
              targetPosition: _latestPlaybackPosition ?? 0,
              shouldPlay: _latestIsPlaying,
            ).attemptInitialSync();
            if (synced) _hasSynced = true;
          }
        },
        onNavigationRequest: (request) {
          if (_isExternal(request.url)) {
            _launchUrl(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      );

  bool _isExternal(String url) =>
      url.startsWith('tel') ||
      url.contains('play.google.com') ||
      url.contains('apps.apple.com') ||
      url.startsWith('mailto');

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (_) {
      CoreUtils.showSnackBar(context, 'Failed to open external link.');
    }
  }

  void _updateSyncBadge(SyncStatus status) {
    if (_isHost || _syncStatus == status) return;

    setState(() {
      _syncStatus = status;
      _showSyncBadge = true;
    });

    _syncBadgeTimer?.cancel();
    if (status == SyncStatus.synced) {
      _syncBadgeTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSyncBadge = false);
      });
    }
  }

  void _confirmEndParty() {
    showDialog(
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
            onPressed: () {
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
    if (_webViewController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) async {
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

          final localPosition = await playback
              .getCurrentTime(streamingPlatform.currentTimeScript);
          final drift = (_latestPlaybackPosition! - localPosition).abs();
          _updateSyncBadge(
              drift < 3.0 ? SyncStatus.synced : SyncStatus.syncing);

          if (drift >= 1.5) await playback.seek(_latestPlaybackPosition!);
          final playing = await playback.isPlaying();
          if (state.isPlaying != playing) {
            state.isPlaying ? await playback.play() : await playback.pause();
          }
        }

        if (state is WatchPartyLeft ||
            state is WatchPartyEnded ||
            state is WatchPartyEndedByHost) {
          CoreUtils.showSnackBar(context, 'The host ended the watch party');
          try {
            await playback.pause();
          } catch (_) {
            debugPrint('Could not pause playback.');
          }
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          }
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _isHost ? _confirmEndParty() : _leaveParty();
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.watchParty.title),
              leading: _isHost
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'End Watch Party',
                      onPressed: _confirmEndParty,
                    )
                  : null,
              actions: [
                IconButton(
                  icon:
                      Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline),
                  onPressed: () => setState(() => _showChat = !_showChat),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: loadingPercentage < 100
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  value: loadingPercentage / 100),
                              const SizedBox(height: 12),
                              Text('Loading... $loadingPercentage%'),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            WebViewWidget(controller: _webViewController!),
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
                          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
                        ),
                      ),
                      child: WatchPartyChat(partyId: widget.watchParty.id),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: _isHost
                ? WebPlaybackControls(
                    controller: _webViewController!,
                    watchParty: widget.watchParty,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
