import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
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
  bool? _latestIsPlaying;
  bool _hasInitialSynced = false;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _stopAutoSyncLoop();
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    final validUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl.startsWith('http')
            ? widget.watchParty.videoUrl
            : 'https://${widget.watchParty.videoUrl}';

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(_navigationDelegate)
      ..loadRequest(Uri.parse(validUrl));

    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      await (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
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
        final result = await _webViewController?.runJavaScriptReturningResult(
          "document.querySelector('video')?.currentTime",
        );
        final position = double.tryParse(result.toString()) ?? 0;

        final isPlayingResult =
            await _webViewController?.runJavaScriptReturningResult(
          "document.querySelector('video')?.paused === false",
        );
        final isPlaying = isPlayingResult.toString() == 'true';

        context.read<WatchPartySessionBloc>().add(
              SendSyncDataEvent(
                partyId: widget.watchParty.id,
                playbackPosition: position,
                isPlaying: isPlaying,
              ),
            );
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
    final jsCommand = """
      var video = document.querySelector('video');
      if (video) {
        video.currentTime = $seconds;
      }
    """;

    try {
      await _webViewController?.runJavaScript(jsCommand);
    } catch (e) {
      debugPrint('Error running JavaScript to seek video: $e');
    }
  }

  Future<void> _playVideo() async {
    try {
      await _webViewController?.runJavaScript("""
          var video = document.querySelector('video');
          if (video) {
            video.muted = false;
            video.volume = 1.0;
            video.play();
          }
          """);
    } catch (e) {
      debugPrint('Error running JS to play video: $e');
    }
    _startAutoSyncLoop();
  }

  Future<void> _pauseVideo() async {
    try {
      await _webViewController
          ?.runJavaScript("""document.querySelector('video')?.pause();""");
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
    ;
    const maxAttempts = 10;
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final result = await _webViewController?.runJavaScriptReturningResult(
          "document.querySelector('video') !== null",
        );
        if (result.toString() == 'true') {
          await _disableGuestVideoControls();
          await _seekToPosition(_latestPlaybackPosition!);

          await _webViewController?.runJavaScript("""
            var video = document.querySelector('video');
            if (video) {
              video.muted = false;
              video.volume = 1.0;
            }
          """);

          if (_latestIsPlaying == true) {
            await _playVideo();
            final confirmedPlay =
                await _webViewController?.runJavaScriptReturningResult(
              "document.querySelector('video')?.paused === false",
            );
            if (confirmedPlay.toString() == 'true') {
              _hasInitialSynced = true;
              return;
            }
          } else {
            await _pauseVideo();
            final confirmedPause =
                await _webViewController?.runJavaScriptReturningResult(
              "document.querySelector('video')?.paused === true",
            );

            if (confirmedPause.toString() == 'true') {
              _hasInitialSynced = true;
            }
          }
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageStarted: (_) => setState(() => loadingPercentage = 0),
        onPageFinished: (_) async {
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
        await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalNonBrowserApplication);
      } else if (url.contains('apps.apple.com') && Platform.isIOS) {
        await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalNonBrowserApplication);
      } else if (url.startsWith('mailto')) {
        await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalNonBrowserApplication);
      } else {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to open external link.');
    }
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
          _latestIsPlaying = state.isPlaying;

          if (_isHost) return;

          if (!_hasInitialSynced && _webViewController != null) {
            await Future.delayed(const Duration(
                milliseconds: 500)); // wait for WebView to settle
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
              "document.querySelector('video')?.currentTime",
            );
            final localPosition = double.tryParse(result.toString()) ?? 0;

            final drift = (state.playbackPosition - localPosition).abs();
            setState(() {
              _syncStatus =
                  drift < 2.0 ? SyncStatus.synced : SyncStatus.syncing;
            });

            // Only seek if drift is large enough
            if (drift > 1.5) {
              await _seekToPosition(state.playbackPosition);
            }

            // Check play/pause difference * only if drift is small enough
            if (drift < 2.0) {
              final playState =
                  await _webViewController?.runJavaScriptReturningResult(
                "document.querySelector('video')?.paused === false",
              );
              final isActuallyPlaying = playState.toString() == 'true';

              if (state.isPlaying && !isActuallyPlaying) {
                await _playVideo();
              } else if (!state.isPlaying && isActuallyPlaying) {
                await _pauseVideo();
              }
            }
          } catch (e) {
            debugPrint('Sync update error: $e');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.watchParty.title),
          actions: [
            IconButton(
              icon: Icon(_showChat ? Icons.chat : Icons.chat_bubble_outline),
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
        bottomNavigationBar: _isHost
            ? WebPlaybackControls(
                controller: _webViewController!,
                watchPartyId: widget.watchParty.id,
              )
            : null,
      ),
    );
  }
}
