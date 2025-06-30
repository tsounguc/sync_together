import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/utils/video_url_helper.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformVideoPickerScreen extends StatefulWidget {
  const PlatformVideoPickerScreen({
    required this.watchParty,
    required this.platform,
    super.key,
  });

  final WatchParty watchParty;
  final StreamingPlatform platform;

  static const String id = '/video-picker';

  @override
  State<PlatformVideoPickerScreen> createState() =>
      _PlatformVideoPickerScreenState();
}

class _PlatformVideoPickerScreenState extends State<PlatformVideoPickerScreen> {
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final rawUrl = message.message;
          final platformName = widget.platform.name.toLowerCase();
          debugPrint('[PlatformVideoPicker] onMessageReceived: $rawUrl');

          String? embedUrl;
          if (platformName == 'vimeo') {
            final id = VideoUrlHelper.extractVimeoVideoId(rawUrl);
            if (id.isNotEmpty) {
              embedUrl =
                  VideoUrlHelper.getEmbedUrl(rawUrl, widget.platform.name);
            }
          } else if (platformName == 'dailymotion') {
            final id = VideoUrlHelper.extractDailymotionVideoId(rawUrl);
            if (id.isNotEmpty) {
              embedUrl =
                  VideoUrlHelper.getEmbedUrl(rawUrl, widget.platform.name);
            }
          } else if (platformName == 'youtube') {
            final id = VideoUrlHelper.extractYoutubeVideoId(rawUrl);
            if (id.isNotEmpty) {
              embedUrl =
                  VideoUrlHelper.getEmbedUrl(rawUrl, widget.platform.name);
            }
          } else if (platformName == 'ted') {
            final id = VideoUrlHelper.extractTedVideoId(rawUrl);
            if (id.isNotEmpty) {
              embedUrl =
                  VideoUrlHelper.getEmbedUrl(rawUrl, widget.platform.name);
            }
          }

          if (embedUrl != null) {
            debugPrint('[PlatformVideoPicker] Posting embed URL: $embedUrl');
            context.read<WatchPartySessionBloc>().add(
                  UpdateVideoUrlEvent(
                    partyId: widget.watchParty.id,
                    newUrl: embedUrl,
                  ),
                );
          } else {
            debugPrint(
                '[PlatformVideoPicker] No video ID could be extracted from: $rawUrl');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (widget.platform.name.toLowerCase() == 'vimeo') {
              final vimeoId = VideoUrlHelper.extractVimeoVideoId(url);
              if (vimeoId.isNotEmpty) {
                final embedUrl =
                    VideoUrlHelper.getEmbedUrl(url, widget.platform.name);
                debugPrint(
                    '[PlatformVideoPicker] Intercepted Vimeo ID: $vimeoId');
                context.read<WatchPartySessionBloc>().add(
                      UpdateVideoUrlEvent(
                        partyId: widget.watchParty.id,
                        newUrl: embedUrl,
                      ),
                    );
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            debugPrint(url);
            if (widget.platform.name.toLowerCase() == 'youtube') {
              _webViewController?.runJavaScript('''
              (function() {
                let lastUrl = location.href;
                new MutationObserver(() => {
                  const currentUrl = location.href;
                  if (currentUrl !== lastUrl && currentUrl.includes('watch?v=')) {
                    lastUrl = currentUrl;
                    window.Flutter.postMessage(currentUrl);
                    history.back();
                  }
                }).observe(document.body, { childList: true, subtree: true });
              })();
            ''');
            } else if (widget.platform.name.toLowerCase() == 'dailymotion') {
              _webViewController?.runJavaScript(r'''
              (function() {
                let lastUrl = location.href;
                new MutationObserver(() => {
                  const currentUrl = location.href;
                  const match = currentUrl.match(/dailymotion\.com\/video\/([^_?&#\/]+)/);
                  if (currentUrl !== lastUrl && match) {
                    lastUrl = currentUrl;
                    window.Flutter.postMessage(currentUrl);
                    history.back();
                  }
                }).observe(document.body, { childList: true, subtree: true });
              })();
            ''');
            } else if (widget.platform.name.toLowerCase() == 'ted') {
              _webViewController?.runJavaScript('''
    (function() {
      let lastUrl = location.href;
      new MutationObserver(() => {
        const currentUrl = location.href;
        if (currentUrl !== lastUrl && currentUrl.includes('/talks/')) {
          lastUrl = currentUrl;
          window.Flutter.postMessage(currentUrl);
          history.back();
        }
      }).observe(document.body, { childList: true, subtree: true });
    })();
  ''');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.platform.defaultUrl));
  }

  void _goToWatchParty(WatchParty party) {
    Navigator.popUntil(
      context,
      ModalRoute.withName('/'),
    );

    Navigator.pushNamed(
      context,
      WatchPartyScreen.id,
      arguments: WatchPartyScreenArguments(
        party,
        party.platform,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) {
        if (state is VideoUrlUpdated) {
          debugPrint('Video URL updated. Starting party...');
          context.read<WatchPartySessionBloc>().add(
                StartPartyEvent(
                  widget.watchParty.id,
                ),
              );
        }
        if (state is WatchPartyStarted) {
          debugPrint('Watch party started. Fetching latest party...');
          context.read<WatchPartySessionBloc>().add(
                GetWatchPartyEvent(
                  widget.watchParty.id,
                ),
              );
        }
        if (state is WatchPartyFetched) {
          debugPrint('Party fetched: ${state.watchParty.videoUrl}');
          _goToWatchParty(state.watchParty);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Pick a Video (${widget.platform.name})')),
        body: _webViewController == null
            ? const Center(child: CircularProgressIndicator())
            : WebViewWidget(controller: _webViewController!),
      ),
    );
  }
}
