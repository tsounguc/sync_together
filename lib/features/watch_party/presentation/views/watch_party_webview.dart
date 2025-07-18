import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/core/utils/video_url_helper.dart';
import 'package:sync_together/core/utils/webview_loader.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';
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
  const WatchPartyWebView({
    required this.watchParty,
    super.key,
  });

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
  bool _showSyncBadge = false;
  SyncStatus _syncStatus = SyncStatus.synced;
  Timer? _syncBadgeTimer;

  double? _latestPlaybackPosition;
  bool _latestIsPlaying = false;
  bool _hasSynced = false;

  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();

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
    syncManager.stop();
    _syncBadgeTimer?.cancel();
    _webViewController = null;
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    // initialize and instantiate variables
    streamingPlatform = widget.watchParty.platform;

    final bloc = context.read<WatchPartySessionBloc>();

    final rawUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl;

    final embedUrl = VideoUrlHelper.getEmbedUrl(rawUrl, streamingPlatform.name);
    final controller = await WebviewLoader.create(
      embedUrl: embedUrl,
      navigationDelegate: _navigationDelegate,
      onUserTappedPlay: _onGuestTappedPlay,
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

  Future<void> _onGuestTappedPlay() async {
    if (_isHost || _hasSynced) return;

    final synced = await GuestSyncHelper(
      playback: playback,
      targetPosition: _latestPlaybackPosition ?? 0,
      shouldPlay: _latestIsPlaying,
    ).attemptInitialSync();
    if (!mounted) return;
    if (synced) {
      debugPrint('Guest manually tapped play and synced successfully.');

      setState(() => _hasSynced = true);
    }
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => loadingPercentage = progress);
        },
        onPageStarted: (_) {
          if (!mounted) return;
          setState(() => loadingPercentage = 0);
        },
        onPageFinished: (_) async {
          if (!mounted) return;
          setState(() => loadingPercentage = 100);

          final embedBlocked =
              await _webViewController?.runJavaScriptReturningResult(
            '''
    document.body.innerText.includes("Video unavailable") 
    || document.body.innerText.includes("Watch this video on YouTube");
    ''',
          );

          if (embedBlocked.toString().toLowerCase() == 'true') {
            debugPrint(
                '[WatchParty] YouTube embed is blocked – opening dialog');
            if (mounted) _showEmbedErrorDialog();
          }
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

  void _showEmbedErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Unable to Load Video'),
        content: Text(
          'This video cannot be embedded due to restrictions. '
          'You can open it directly in the ${streamingPlatform.name} '
          'app instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _launchUrl(widget.watchParty.videoUrl);
            },
            child: Text('Open in ${streamingPlatform.name}'),
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

    return MultiBlocListener(
      listeners: [
        BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
          listener: (context, state) async {
            if (state is SyncUpdated) {
              _latestPlaybackPosition = state.playbackPosition;

              // Update guests about host video playing status
              if (!_isHost && _latestIsPlaying != state.isPlaying) {
                CoreUtils.showSnackBar(
                  context,
                  state.isPlaying
                      ? 'The host started the video'
                      : 'The host paused the video',
                );
              }

              // update saved playing status
              _latestIsPlaying = state.isPlaying;

              // if guest not synced
              if (!_isHost && !_hasSynced) {
                // sync guest
                final synced = await GuestSyncHelper(
                  playback: playback,
                  targetPosition: _latestPlaybackPosition ?? 0,
                  shouldPlay: _latestIsPlaying,
                ).attemptInitialSync();
                if (synced) _hasSynced = true;
              }

              // get the video position from device
              final localPosition = await playback
                  .getCurrentTime(streamingPlatform.currentTimeScript);

              // compare to saved host video positon from database (firebase)
              final drift = (_latestPlaybackPosition! - localPosition).abs();

              // update sync badge if difference is less then 3
              _updateSyncBadge(
                  drift < 3.0 ? SyncStatus.synced : SyncStatus.syncing);

              // set the video to host position if difference is greater than 1.5
              if (drift >= 1.5) await playback.seek(_latestPlaybackPosition!);

              // get video playing status
              final playing = await playback.isPlaying();

              // if host is playing status is different from guest
              if (state.isPlaying != playing) {
                state.isPlaying
                    ? await playback.play()
                    : await playback.pause();
              }
            }

            if (state is WatchPartyLeft) {
              await syncManager.stop();
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
                CoreUtils.showSnackBar(
                    context, 'The host ended the watch party');

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
          },
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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _isHost ? _confirmEndParty() : _leaveParty();
        },
        child: SafeArea(
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
                      _showChat ? Icons.chat : Icons.chat_bubble_outline,
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() => _showChat = !_showChat);
                    },
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
              // bottomNavigationBar: _isHost
              //     ? WebPlaybackControls(
              //         syncManager: syncManager,
              //       )
              //     : null,
            ),
          ),
        ),
      ),
    );
  }
}
