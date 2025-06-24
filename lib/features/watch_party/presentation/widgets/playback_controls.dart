import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// **PlaybackControls Widget**
///
/// Provides UI controls for controlling video playback inside the WebView.
/// This includes **Play, Pause, and Sync** functionality.
class WebPlaybackControls extends StatefulWidget {
  const WebPlaybackControls({
    required this.controller,
    required this.watchPartyId,
    super.key,
  });

  /// The WebView controller that loads the streaming service.
  final WebViewController controller;

  /// The ID of the watch party.
  final String watchPartyId;

  @override
  State<WebPlaybackControls> createState() => _WebPlaybackControlsState();
}

class _WebPlaybackControlsState extends State<WebPlaybackControls> {
  var _isPlaying = false;

  /// **Play the void and sync position**
  Future<void> _playVideo(BuildContext context) async {
    const playScript = "document.querySelector('video')?.play();";
    await widget.controller.runJavaScript(playScript);
    _isPlaying = true;
    await _syncPlayback(context, true);

    CoreUtils.showSnackBar(context, 'You started playing the video.');
  }

  /// **Pause the video and sync position**
  Future<void> _pauseVideo(BuildContext context) async {
    const pauseScript = "document.querySelector('video')?.pause();";
    await widget.controller.runJavaScript(pauseScript);
    _isPlaying = false;
    await _syncPlayback(context, false);

    CoreUtils.showSnackBar(context, 'You paused the video');
  }

  /// **Fetches the current playback position & syncs it across users.**
  Future<void> _syncPlayback(BuildContext context, bool isPlaying) async {
    const script = "document.querySelector('video')?.currentTime";
    final result = await widget.controller.runJavaScriptReturningResult(script);

    if (result != null) {
      final position = double.tryParse(result.toString()) ?? 0;
      context.read<WatchPartySessionBloc>().add(
            SendSyncDataEvent(
              partyId: widget.watchPartyId,
              playbackPosition: position,
              isPlaying: isPlaying,
            ),
          );
      CoreUtils.showSnackBar(
        context,
        'Playback synchronized!',
      );
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
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () => _syncPlayback(context, _isPlaying),
        ),
      ],
    );
  }
}
