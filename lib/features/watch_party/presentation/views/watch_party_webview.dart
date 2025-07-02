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
import 'package:sync_together/features/watch_party/presentation/widgets/web_playback_controls.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_status_badge.dart';
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
  SyncStatus _syncStatus = SyncStatus.synced;
  bool _showSyncBadge = true;
  Timer? _syncBadgeTimer;

  // Guest sync memory
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
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    streamingPlatform = widget.watchParty.platform;
    final bloc = context.read<WatchPartySessionBloc>();
    final rawUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl;

    final embedUrl =
        VideoUrlHelper.getEmbedUrl(rawUrl, widget.watchParty.platform.name);

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

    if (mounted) {
      setState(() {
        _webViewController = controller;
      });
    }

    if (_isHost) {
      syncManager.start();
    } else {
      bloc.add(
        GetSyncedDataEvent(
          partyId: widget.watchParty.id,
        ),
      );
    }

    bloc.add(
      ListenToPartyExistenceEvent(
        widget.watchParty.id,
      ),
    );
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
        onPageFinished: (url) async {
          if (!mounted) return;
          setState(() => loadingPercentage = 100);

          if (!_isHost) {
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

  bool _isExternal(String url) {
    return url.startsWith('tel') ||
        url.contains('play.google.com') ||
        url.contains('apps.apple.com') ||
        url.startsWith('mailto');
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalNonBrowserApplication,
      );
    } catch (_) {
      if (mounted) {
        CoreUtils.showSnackBar(
          context,
          'Failed to open external link.',
        );
      }
    }
  }

  void _updateSyncBadge(SyncStatus status) {
    if (_isHost || status == _syncStatus) return;

    if (!mounted) return;
    setState(() {
      _syncStatus = status;
      _showSyncBadge = true;
    });

    _syncBadgeTimer?.cancel();
    if (status == SyncStatus.synced) {
      _syncBadgeTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() => _showSyncBadge = false);
      });
    }
  }

  void _confirmEndParty(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Watch Party?'),
        content: const Text('This will disconnect all guests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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

  void _leaveParty(BuildContext context) {
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

    String? lastGuestNotice;
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) async {
        if (state is SyncUpdated) {
          _latestPlaybackPosition = state.playbackPosition;

          if (!_isHost) {
            // Show guest SnackBar if play/pause changed
            if (_latestIsPlaying != state.isPlaying) {
              if (state.isPlaying) {
                lastGuestNotice = 'The host started the video';
              } else {
                lastGuestNotice = 'The host paused the video';
              }
              CoreUtils.showSnackBar(context, lastGuestNotice!);
            }
          }

          _latestIsPlaying = state.isPlaying;

          if (_isHost) return;

          if (!_hasSynced) {
            final synced = await GuestSyncHelper(
              playback: playback,
              targetPosition: _latestPlaybackPosition ?? 0,
              shouldPlay: _latestIsPlaying,
            ).attemptInitialSync();
            if (!mounted) return;
            if (synced) _hasSynced = true;
          }

          final localPosition = await playback.getCurrentTime(
            streamingPlatform.currentTimeScript,
          );
          final drift = (_latestPlaybackPosition! - localPosition).abs();

          _updateSyncBadge(
              drift < 3.0 ? SyncStatus.synced : SyncStatus.syncing);

          if (drift >= 1.5) {
            await playback.seek(_latestPlaybackPosition!);
          }

          final playing = await playback.isPlaying();
          if (state.isPlaying != playing) {
            state.isPlaying ? await playback.play() : await playback.pause();
          }
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
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if (_isHost) {
            _confirmEndParty(context);
          } else {
            _leaveParty(context);
          }
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.watchParty.title),
              leading: _isHost
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'End Watch Party',
                      onPressed: () => _confirmEndParty(context),
                    )
                  : null,
              actions: [
                IconButton(
                  icon: Icon(
                    _showChat ? Icons.chat : Icons.chat_bubble_outline,
                  ),
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
                                value: loadingPercentage / 100,
                              ),
                              const SizedBox(height: 16),
                              Text('Loading... $loadingPercentage%'),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            WebViewWidget(controller: _webViewController!),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: !_isHost
                                  ? AnimatedOpacity(
                                      opacity: _showSyncBadge ? 1.0 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: SyncStatusBadge(
                                        status: _syncStatus,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
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
