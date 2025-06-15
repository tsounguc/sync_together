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

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS/macOS features.
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

  @override
  void initState() {
    super.initState();
    _initializeWebView();

    if (_isHost) {
      // Start sending sync updates as host
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoSyncLoop();
      });
    }

    // context.read<WatchPartySessionBloc>().add(
    //       GetSyncedDataEvent(
    //         partyId: widget.watchParty.id,
    //       ),
    //     );
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
        video.muted = true;
        video.currentTime = $seconds;
        video.play();
      }
    """;

    try {
      await _webViewController?.runJavaScript(jsCommand);
    } catch (e) {
      debugPrint('Error running JavaScript to seek video: $e');
    }
  }

  Future<void> _playVideo() async {
    await _webViewController
        ?.runJavaScript("document.querySelector('video')?.play();");
    _startAutoSyncLoop();
  }

  Future<void> _pauseVideo() async {
    await _webViewController
        ?.runJavaScript("document.querySelector('video')?.pause();");
    _stopAutoSyncLoop();
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageStarted: (_) => setState(() => loadingPercentage = 0),
        onPageFinished: (_) => setState(() => loadingPercentage = 100),
        onNavigationRequest: (request) {
          if (_isExternalLink(request.url)) {
            _handleExternalLink(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        // onUrlChange: (UrlChange change) {
        //   final newUrl = change.url ?? '';
        //   if (newUrl.isNotEmpty && newUrl != widget.watchParty.videoUrl) {
        //     if (context.currentUser?.uid == widget.watchParty.hostId) {
        //       context.read<WatchPartySessionBloc>().add(
        //             UpdateVideoUrlEvent(
        //               partyId: widget.watchParty.id,
        //               newUrl: newUrl,
        //             ),
        //           );
        //     }
        //   }
        // },
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
        if (state is SyncUpdated && !_isHost) {
          final remotePos = state.playbackPosition;
          final remoteIsPlaying = state.isPlaying;

          debugPrint(
              'Sync update received:  position=${state.playbackPosition}');

          final localPositionResult =
              await _webViewController?.runJavaScriptReturningResult(
            "document.querySelector('video')?.currentTime",
          );
          final localPosition =
              double.tryParse(localPositionResult.toString()) ?? 0;
          final drift = (remotePos - localPosition).abs();

          // Update sync status
          setState(() {
            _syncStatus = drift < 2.0 ? SyncStatus.synced : SyncStatus.syncing;
          });

          // Seek only if the drift is large enough
          if (drift > 1.5) {
            await _seekToPosition(remotePos);
          }

          final isPlayingResult =
              await _webViewController?.runJavaScriptReturningResult(
            "document.querySelector('video')?.paused === false",
          );

          final isActuallyPlaying = isPlayingResult.toString() == 'true';

          if (remoteIsPlaying && !isActuallyPlaying) {
            await _playVideo();
          } else if (!remoteIsPlaying && isActuallyPlaying) {
            await _pauseVideo();
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
                  child: WatchPartyChat(
                    partyId: widget.watchParty.id,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: WebPlaybackControls(
          controller: _webViewController!,
          watchPartyId: widget.watchParty.id,
        ),
      ),
    );
  }
}
