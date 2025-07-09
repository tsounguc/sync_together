import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/utils/video_url_helper.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/themes/app_theme.dart';
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
  bool _isLoading = true;
  double _fadeOpacity = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _fadeOpacity = 1.0);
      }
    });
  }

  void _initWebView() {
    final backgroundColor = AppTheme.darkTheme.scaffoldBackgroundColor;
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(backgroundColor)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final rawUrl = message.message;
          final platformName = widget.platform.name.toLowerCase();
          debugPrint('[PlatformVideoPicker] onMessageReceived: $rawUrl');

          String? embedUrl;

          if (platformName == 'youtube') {
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
            debugPrint('[PlatformVideoPicker] Could not extract video ID');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            final platform = widget.platform.name.toLowerCase();
            if (platform == 'youtube') {
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
            } else if (platform == 'ted') {
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
          onNavigationRequest: (request) {
            final url = request.url;
            final platform = widget.platform.name.toLowerCase();
            if (platform == 'vimeo') {
              final id = VideoUrlHelper.extractVimeoVideoId(url);
              if (id.isNotEmpty) {
                final embedUrl =
                    VideoUrlHelper.getEmbedUrl(url, widget.platform.name);
                debugPrint('[PlatformVideoPicker] Intercepted Vimeo ID: $id');
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
        ),
      )
      ..loadRequest(Uri.parse(widget.platform.defaultUrl));
  }

  Future<void> _goToWatchParty(WatchParty party) async {
    final navigator = Navigator.of(context);
    navigator.popUntil(ModalRoute.withName('/'));
    await navigator.pushNamed(
      WatchPartyScreen.id,
      arguments: WatchPartyScreenArguments(party, party.platform),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) {
        if (state is VideoUrlUpdated) {
          debugPrint('Video URL updated. Starting party...');
          context.read<WatchPartySessionBloc>().add(
                StartPartyEvent(widget.watchParty.id),
              );
        }
        if (state is WatchPartyStarted) {
          debugPrint('Watch party started. Fetching latest party...');
          context.read<WatchPartySessionBloc>().add(
                GetWatchPartyEvent(widget.watchParty.id),
              );
        }
        if (state is WatchPartyFetched) {
          debugPrint('Party fetched: ${state.watchParty.videoUrl}');
          _goToWatchParty(state.watchParty);
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('Pick a Video (${widget.platform.name})'),
            backgroundColor: Colors.black,
          ),
          body: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                opacity: _fadeOpacity,
                child: _webViewController == null
                    ? const SizedBox.shrink()
                    : WebViewWidget(controller: _webViewController!),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
          bottomNavigationBar:
              _webViewController != null ? _buildWebNavigationBar() : null,
        ),
      ),
    );
  }

  Widget _buildWebNavigationBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            tooltip: 'Back',
            onPressed: () async {
              if (await _webViewController?.canGoBack() ?? false) {
                _webViewController?.goBack();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reload',
            onPressed: () => _webViewController?.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            tooltip: 'Forward',
            onPressed: () async {
              if (await _webViewController?.canGoForward() ?? false) {
                _webViewController?.goForward();
              }
            },
          ),
        ],
      ),
    );
  }
}
