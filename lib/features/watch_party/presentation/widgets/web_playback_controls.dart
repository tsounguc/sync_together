import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controller.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/sync_manager.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// **PlaybackControls Widget**
///
/// Provides UI controls for controlling video playback inside the WebView.
/// This includes **Play, Pause, and Sync** functionality.
class WebPlaybackControls extends StatefulWidget {
  const WebPlaybackControls({
    required this.controller,
    required this.watchParty,
    super.key,
  });

  /// The WebView controller that loads the streaming service.
  final WebViewController controller;

  /// The ID of the watch party.
  final WatchParty watchParty;

  @override
  State<WebPlaybackControls> createState() => _WebPlaybackControlsState();
}

class _WebPlaybackControlsState extends State<WebPlaybackControls> {
  late final PlaybackController playback;
  var _isPlaying = false;

  @override
  void initState() {
    super.initState();
    playback = PlaybackController(
      controller: widget.controller,
      platform: widget.watchParty.platform,
    );
  }

  /// **Play the void and sync position**
  Future<void> _playVideo(BuildContext context) async {
    try {
      await playback.play();
      _isPlaying = true;
      // await _syncPlayback(context, isPlaying)
      CoreUtils.showSnackBar(context, 'You started playing the video.');
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to play video.');
    }
  }

  /// **Pause the video and sync position**
  Future<void> _pauseVideo(BuildContext context) async {
    try {
      await playback.pause();
      _isPlaying = false;
      CoreUtils.showSnackBar(context, 'You paused the video.');
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to pause video');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () async => _playVideo(context),
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () async => _pauseVideo(context),
        ),
      ],
    );
  }
}
