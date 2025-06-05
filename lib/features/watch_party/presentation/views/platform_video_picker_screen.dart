import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/utils/video_url_helper.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
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
  State<PlatformVideoPickerScreen> createState() => _PlatformVideoPickerScreenState();
}

class _PlatformVideoPickerScreenState extends State<PlatformVideoPickerScreen> {
  WebViewController? _webViewController;
  String? selectedVideoUrl;

  @override
  void initState() {
    super.initState();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setNavigationDelegate(NavigationDelegate(
      //   onNavigationRequest: (request) {
      //     final url = request.url;
      //     debugPrint(url);
      //     final isYoutube = widget.platform.name.toLowerCase() == 'youtube';
      //     if (isYoutube && url.contains('watch?v')) {
      //       setState(() {
      //         selectedVideoUrl = url;
      //       });
      //       return NavigationDecision.prevent;
      //     }
      //
      //     return NavigationDecision.navigate;
      //   },
      //   onPageFinished: (url) {
      //     if (widget.platform.name.toLowerCase() == 'youtube') {
      //       _webViewController?.runJavaScript('''
      //         const observer = new MutationObserver(() => {
      //           const url = window.location.href;
      //           if (url.includes('watch?v=')) {
      //             window.Flutter.postMessage(url);
      //           }
      //         });
      //         observer.observe(document.body, { childList: true, subtree: true });
      //       ''');
      //     }
      //   },
      // ))
      ..setNavigationDelegate(NavigationDelegate()) // No need to block navigation now
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (message) {
          final url = message.message;
          final embeddedUrl = VideoUrlHelper.getEmbedUrl(
            url,
            widget.platform.name,
          );
          if (url.contains('watch?v=')) {
            context.read<WatchPartySessionBloc>().add(
                  UpdateVideoUrlEvent(
                    partyId: widget.watchParty.id,
                    newUrl: embeddedUrl,
                  ),
                );

            Navigator.pushReplacementNamed(
              context,
              WatchPartyScreen.id,
              arguments: WatchPartyScreenArguments(
                (widget.watchParty as WatchPartyModel).copyWith(
                  videoUrl: embeddedUrl,
                  hasStarted: true,
                ),
                widget.platform,
              ),
            );
          }
        },
      )
      ..loadRequest(Uri.parse(widget.platform.defaultUrl));

    _webViewController = controller;

    controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
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
        }
      },
    ));
  }

  void _startWatchParty() {
    if (selectedVideoUrl == null) return;

    context.read<WatchPartySessionBloc>().add(
          UpdateVideoUrlEvent(
            partyId: widget.watchParty.id,
            newUrl: selectedVideoUrl!,
          ),
        );

    Navigator.pushReplacementNamed(
      context,
      WatchPartyScreen.id,
      arguments: WatchPartyScreenArguments(
        (widget.watchParty as WatchPartyModel).copyWith(
          videoUrl: selectedVideoUrl,
          hasStarted: true,
        ),
        widget.platform,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick a Video (${widget.platform.name})')),

      body: _webViewController == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _webViewController!),
      // body: Stack(
      //   children: [
      //     if (_webViewController == null)
      //       const Center(child: CircularProgressIndicator())
      //     else
      //       WebViewWidget(controller: _webViewController!),
      //     if (selectedVideoUrl != null)
      //       Positioned(
      //         bottom: 24,
      //         left: 24,
      //         right: 24,
      //         child: ElevatedButton.icon(
      //           onPressed: _startWatchParty,
      //           icon: const Icon(Icons.play_arrow),
      //           label: const Text('Start Watch Party'),
      //         ),
      //       ),
      //   ],
      // ),
    );
  }
}
