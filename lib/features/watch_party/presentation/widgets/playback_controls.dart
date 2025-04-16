import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({
    required this.watchPartyId,
    required this.currentPosition,
    super.key,
  });

  final String watchPartyId;
  final double currentPosition;

  void _sendPlaybackUpdate(BuildContext context, bool isPlaying) {
    context.read<WatchPartyBloc>().add(
          SyncPlaybackEvent(
            watchPartyId: watchPartyId,
            playbackPosition: currentPosition,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPlaying ? 'You are playing.' : 'You paused the video.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _syncWithHost(BuildContext context) {
    context.read<WatchPartyBloc>().add(GetSyncedDataEvent(watchPartyId: watchPartyId));
    CoreUtils.showSnackBar(
      context,
      'Synced with host!',
      durationInMilliSecond: 2000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Let others know what you're doing:",
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => _sendPlaybackUpdate(context, true),
              icon: const Icon(
                Icons.play_arrow,
                size: 15,
              ),
              label: const Text(
                'I\'m Playing',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _sendPlaybackUpdate(context, false),
              icon: const Icon(Icons.pause,size: 15,),
              label: const Text('I Paused',style: TextStyle(
                fontSize: 12,
              ),),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _syncWithHost(context),
          icon: const Icon(Icons.sync,size: 15,),
          label: const Text('Sync with Host',style: TextStyle(
            fontSize: 12,
          ),),
        ),
      ],
    );
  }
}

/// **PlaybackControls Widget**
///
/// Provides UI controls for controlling video playback inside the WebView.
/// This includes **Play, Pause, and Sync** functionality.
class WebPlaybackControls extends StatelessWidget {
  const WebPlaybackControls({
    required this.controller,
    required this.watchPartyId,
    super.key,
  });

  /// The WebView controller that loads the streaming service.
  final WebViewController controller;

  /// The ID of the watch party.
  final String watchPartyId;

  /// **Injects JavaScript to play/pause the video.**
  Future<void> _togglePlayback(BuildContext context) async {
    const script = """
      var video = document.querySelector('video');
      if (video) {
        if (video.paused) {
          video.play();
        } else {
          video.pause();
        }
      }
    """;
    await controller.runJavaScript(script);

    await _syncPlayback(context);
  }

  /// **Fetches the current playback position & syncs it across users.**
  Future<void> _syncPlayback(BuildContext context) async {
    const script = "document.querySelector('video')?.currentTime";
    final result = await controller.runJavaScriptReturningResult(script);

    if (result != null) {
      final position = double.tryParse(result.toString()) ?? 0;
      context.read<WatchPartyBloc>().add(
            SyncPlaybackEvent(
              watchPartyId: watchPartyId,
              playbackPosition: position,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playback synchronized!'),
          duration: Duration(seconds: 2),
        ),
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
          onPressed: () async => _togglePlayback(context),
        ),
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () async => _togglePlayback(context),
        ),
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: () => _syncPlayback(context),
        ),
      ],
    );
  }
}
