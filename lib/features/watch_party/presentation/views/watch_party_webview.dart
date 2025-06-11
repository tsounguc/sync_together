import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/sync_status.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
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
  Timer? _syncTimer;
  bool _showChat = true;
  SyncStatus _syncStatus = SyncStatus.synced;
  double _lastHostTime = 0;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('Flutter', onMessageReceived: _onJsMessage)
      ..loadFlutterAsset('assets/html/youtube_player.html?v=${_extractVideoId(widget.watchParty.videoUrl)}');

    if (context.currentUser?.uid == widget.watchParty.hostId) {
      _startSyncLoop();
    }
  }

  String _extractVideoId(String url) {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v']!;
    }
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : '';
  }

  void _onJsMessage(JavaScriptMessage message) {
    final data = json.decode(message.message);
    final position = (data['time'] as num?)?.toDouble() ?? 0.0;
    final isPlaying = data['playing'] == true;

    _lastHostTime = position;

    if (context.currentUser?.uid == widget.watchParty.hostId) {
      context.read<WatchPartySessionBloc>().add(
        SendSyncDataEvent(
          partyId: widget.watchParty.id,
          playbackPosition: position,
          isPlaying: isPlaying,
        ),
      );
    }
  }

  void _startSyncLoop() {
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      _controller.runJavaScript("window.Flutter.postMessage(JSON.stringify({ time: player.getCurrentTime(), playing: player.getPlayerState() === 1 }));");
    });
  }

  void _stopSyncLoop() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  @override
  void dispose() {
    _stopSyncLoop();
    super.dispose();
  }

  Future<void> _seekTo(double seconds) async {
    await _controller.runJavaScript("seekTo($seconds);");
  }

  Future<void> _play() async {
    await _controller.runJavaScript("playVideo();");
  }

  Future<void> _pause() async {
    await _controller.runJavaScript("pauseVideo();");
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartySessionBloc, WatchPartySessionState>(
      listener: (context, state) async {
        if (state is SyncUpdated && context.currentUser?.uid != widget.watchParty.hostId) {
          final drift = (state.playbackPosition - _lastHostTime).abs();
          setState(() => _syncStatus = drift < 1.5 ? SyncStatus.synced : SyncStatus.syncing);

          if (drift > 1.5) {
            await _seekTo(state.playbackPosition);
          }

          if (state.isPlaying) {
            await _play();
          } else {
            await _pause();
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
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  Positioned(top: 12, right: 12, child: SyncStatusBadge(status: _syncStatus)),
                ],
              ),
            ),
            if (_showChat)
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  ),
                  child: WatchPartyChat(partyId: widget.watchParty.id),
                ),
              ),
          ],
        ),
        bottomNavigationBar: WebPlaybackControls(
          controller: _controller,
          watchPartyId: widget.watchParty.id,
        ),
      ),
    );
  }
}
