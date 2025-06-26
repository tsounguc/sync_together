import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_status_badge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  int loadingPercentage = 0;

  Timer? _playbackSyncTimer;
  bool _showChat = true;
  SyncStatus _syncStatus = SyncStatus.synced;

  bool get _isHost => context.currentUser?.uid == widget.watchParty.hostId;

  // New: Local memory of latest sync state
  double? _latestPlaybackPosition;
  bool _latestIsPlaying = false;
  bool _hasInitialSynced = false;

  bool _showSyncBadge = true;
  Timer? _syncBadgeTimer;

  late final StreamingPlatform streamingPlatform;

  @override
  void initState() {
    super.initState();
    streamingPlatform = widget.watchParty.platform;
    _initializeWebView();

    if (_isHost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoSyncLoop();
      });
    } else {
      context.read<WatchPartySessionBloc>().add(
            GetSyncedDataEvent(
              partyId: widget.watchParty.id,
            ),
          );
    }

    context.read<WatchPartySessionBloc>().add(
          ListenToPartyExistenceEvent(
            widget.watchParty.id,
          ),
        );
  }

  @override
  void dispose() {
    _syncBadgeTimer?.cancel();
    _syncBadgeTimer = null;

    _playbackSyncTimer?.cancel();
    _playbackSyncTimer = null;
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    final validUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl.startsWith('http')
            ? widget.watchParty.videoUrl
            : 'https://${widget.watchParty.videoUrl}';

    late final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(_navigationDelegate)
      ..loadRequest(Uri.parse(validUrl));

    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      final platform = controller.platform as AndroidWebViewController;
      await platform.setMediaPlaybackRequiresUserGesture(false);
    }

    setState(() {
      _webViewController = controller;
    });
  }

  void _startAutoSyncLoop() {
    _playbackSyncTimer?.cancel();
    _playbackSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final hasVideo = await _webViewController?.runJavaScriptReturningResult(
          "document.querySelector('video') !== null",
        );

        debugPrint('has video: $hasVideo');

        if (hasVideo.toString() != 'true') return;

        final result = await _webViewController
            ?.runJavaScriptReturningResult(streamingPlatform.currentTimeScript);
        final position = double.tryParse(result.toString()) ?? 0;

        final isPlayingResult =
            await _webViewController?.runJavaScriptReturningResult(
          streamingPlatform.pauseScript
              .replaceAll('.pause()', '.paused === false'),
        );
        final isPlaying = isPlayingResult.toString() == 'true';

        if (mounted) {
          context.read<WatchPartySessionBloc>().add(
                SendSyncDataEvent(
                  partyId: widget.watchParty.id,
                  playbackPosition: position,
                  isPlaying: isPlaying,
                ),
              );
        }
      } catch (e) {
        debugPrint('Sync timer error: $e');
      }
    });
  }

  void _stopAutoSyncLoop() {
    _playbackSyncTimer?.cancel();
    _playbackSyncTimer = null;
  }

  Future<void> _seekToPosition(double seconds) async {
    final jsCommand = "document.querySelector('video').currentTime = $seconds;";
    await _webViewController?.runJavaScript(jsCommand);
  }

  Future<void> _playVideo() async {
    // await _webViewController?.runJavaScript("""
    //     var video = document.querySelector('video');
    //     if (video) {
    //       video.muted = false;
    //       video.volume = 1.0;
    //       video.play();
    //     }
    //     """);
    await _webViewController?.runJavaScript(streamingPlatform.playScript);
    _startAutoSyncLoop();
  }

  Future<void> _pauseVideo() async {
    try {
      await _webViewController?.runJavaScript(streamingPlatform.pauseScript);
    } catch (e) {
      debugPrint('Error running JS to pause video: $e');
    }
    _stopAutoSyncLoop();
  }

  Future<void> _disableGuestVideoControls() async {
    const js = '''
    var video = document.querySelector('video');
    if (video) {
      video.removeAttribute('controls');
      video.style.pointerEvents = 'none'; // Disable user interactions
      
      video.muted = false;
      video.volume = 1.0;
    }
  ''';

    try {
      await _webViewController?.runJavaScript(js);
    } catch (e) {
      debugPrint('[GuestSync] Failed to disable playback functions: $e');
    }
  }

  Future<void> _attemptInitialGuestSync() async {
    if (_hasInitialSynced || _isHost || _latestPlaybackPosition == null) return;

    const maxAttempts = 10;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final hasVideo = await _webViewController?.runJavaScriptReturningResult(
          "document.querySelector('video') !== null",
        );
        if (hasVideo.toString() == 'true') {
          await _disableGuestVideoControls();
          await _seekToPosition(_latestPlaybackPosition!);

          if (_latestIsPlaying) {
            await _playVideo();
            final confirmedPlay =
                await _webViewController?.runJavaScriptReturningResult(
              streamingPlatform.pauseScript
                  .replaceAll('.pause()', '.paused === false'),
            );
            if (confirmedPlay.toString() == 'true') {
              _hasInitialSynced = true;
              return;
            }
          } else {
            await _pauseVideo();
            final confirmedPause =
                await _webViewController?.runJavaScriptReturningResult(
              streamingPlatform.pauseScript
                  .replaceAll('.pause()', '.paused === true'),
            );

            if (confirmedPause.toString() == 'true') {
              _hasInitialSynced = true;
              return;
            }
          }
        }
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageStarted: (_) => setState(() => loadingPercentage = 0),
        onPageFinished: (url) async {
          setState(() => loadingPercentage = 100);
          await _attemptInitialGuestSync();
          if (!_isHost) await _disableGuestVideoControls();
        },
        onNavigationRequest: (request) {
          if (_isExternalLink(request.url)) {
            _handleExternalLink(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      );

  bool _isExternalLink(String url) {
    return url.startsWith('tel') ||
        url.contains('play.google.com') ||
        url.contains('apps.apple.com') ||
        url.startsWith('mailto');
  }

  Future<void> _handleExternalLink(String url) async {
    try {
      if (url.startsWith('tel')) {
        await launchUrl(Uri(scheme: 'tel', path: url.substring(4)));
      } else if (url.contains('play.google.com') && Platform.isAndroid) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else if (url.contains('apps.apple.com') && Platform.isIOS) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else if (url.startsWith('mailto')) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication,
        );
      } else {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
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

    setState(() {
      _syncStatus = status;
      _showSyncBadge = true;
    });

    _syncBadgeTimer?.cancel();

    if (status == SyncStatus.synced) {
      _syncBadgeTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (_syncStatus == SyncStatus.synced) {
          setState(() => _showSyncBadge = false);
        }
      });
    }
  }

  void _confirmEndParty(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Watch Party?'),
        content: const Text('This will disconnect all guests from the party.'),
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

          if (!_hasInitialSynced && _webViewController != null) {
            // wait for WebView to settle
            await Future<void>.delayed(const Duration(milliseconds: 500));
            await _attemptInitialGuestSync();
          }

          try {
            final hasVideo =
                await _webViewController?.runJavaScriptReturningResult(
              "document.querySelector('video') !== null",
            );

            if (hasVideo.toString() != 'true') return;

            final result =
                await _webViewController?.runJavaScriptReturningResult(
                    streamingPlatform.currentTimeScript);
            final localPosition = double.tryParse(result.toString()) ?? 0;

            final drift = (state.playbackPosition - localPosition).abs();

            // Update sync badge status (for guest only)
            final newStatus =
                drift < 3.0 ? SyncStatus.synced : SyncStatus.syncing;
            if (newStatus != _syncStatus) {
              _updateSyncBadge(newStatus);
            }

            // Do not sync if already synced
            if (drift < 1.5) {
              final playState =
                  await _webViewController?.runJavaScriptReturningResult(
                "document.querySelector('video')?.paused === false",
              );
              final isActuallyPlaying = playState.toString() == 'true';

              if (state.isPlaying != isActuallyPlaying) {
                if (state.isPlaying) {
                  await _playVideo();
                } else {
                  await _pauseVideo();
                }
              }

              return; // Already in sync — skip further actions
            }

            // Drift too high → seek
            await _seekToPosition(state.playbackPosition);

            // Ensure play/pause is correct after seeking
            final playState =
                await _webViewController?.runJavaScriptReturningResult(
              streamingPlatform.pauseScript.replaceAll(
                '.pause()',
                '.paused === false',
              ),
            );
            final isActuallyPlaying = playState.toString() == 'true';

            if (state.isPlaying && !isActuallyPlaying) {
              await _playVideo();
            } else if (!state.isPlaying && isActuallyPlaying) {
              await _pauseVideo();
            }
          } catch (e) {
            debugPrint('Sync update error: $e');
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
                    watchPartyId: widget.watchParty.id,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
