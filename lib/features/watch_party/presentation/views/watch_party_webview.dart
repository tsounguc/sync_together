import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/resources/media_resources.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_status_badge.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WatchPartyWebView extends StatefulWidget {
  const WatchPartyWebView({required this.watchParty, super.key});

  final WatchParty watchParty;

  @override
  State<WatchPartyWebView> createState() => _WatchPartyWebViewState();
}

class _WatchPartyWebViewState extends State<WatchPartyWebView> {
  late final WebViewController _controller;
  double _currentTime = 0;
  bool _isPlaying = false;
  late final String videoId;

  @override
  void initState() {
    super.initState();

    final videoUrl = widget.watchParty.videoUrl;
    print('videoUrl: $videoUrl');

    final start = videoUrl.indexOf('embed/');
    final end = videoUrl.indexOf('?modestbranding');
    final videoId = videoUrl.substring(start + 6, end);
    print('videoId: $videoId');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          final data = jsonDecode(message.message);

          if (data['error'] == true && mounted) {
            final code = data['code'];
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Video unavailable'),
                content: Text(
                    'This video cannot be played (error $code). Try another one.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'))
                ],
              ),
            );
            return;
          }

          setState(() {
            _currentTime = (data['time'] as num?)?.toDouble() ?? 0.0;
            _isPlaying = data['playing'] == true;
          });
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            try {
              await Future.delayed(const Duration(
                  milliseconds: 300)); // give DOM some breathing room
              await _controller.runJavaScript('window.videoId = "$videoId";');
              await _controller.runJavaScript('initializePlayer();');
            } catch (e) {
              debugPrint('JS init error: $e');
            }
          },
        ),
      )
      ..loadFlutterAsset(MediaResources.youtubePlayer);
  }

  Future<void> _waitForPlayerReady() async {
    for (int i = 0; i < 50; i++) {
      // max ~5 seconds
      try {
        final result = await _controller
            .runJavaScriptReturningResult('window.playerReady === true');
        if (result == true || result.toString() == 'true') return;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> playVideo() async {
    await _waitForPlayerReady();
    await _controller.runJavaScript('playVideo();');
  }

  Future<void> pauseVideo() async {
    await _waitForPlayerReady();
    await _controller.runJavaScript('pauseVideo();');
  }

  Future<void> seekTo(double seconds) async {
    await _waitForPlayerReady();
    await _controller.runJavaScript('seekTo($seconds);');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.watchParty.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: WebViewWidget(controller: _controller),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    icon: const Icon(Icons.play_arrow), onPressed: playVideo),
                IconButton(
                    icon: const Icon(Icons.pause), onPressed: pauseVideo),
                IconButton(
                    icon: const Icon(Icons.replay_10),
                    onPressed: () => seekTo(_currentTime - 10)),
                IconButton(
                    icon: const Icon(Icons.forward_10),
                    onPressed: () => seekTo(_currentTime + 10)),
              ],
            ),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                      top: BorderSide(color: Colors.grey.withOpacity(0.3))),
                ),
                child: WatchPartyChat(partyId: widget.watchParty.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
