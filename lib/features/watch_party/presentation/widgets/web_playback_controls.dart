import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/playback_controller.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/sync_manager.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// **WebPlaybackControls Widget**
///
/// Provides clean UI controls for host to control video playback inside the WebView.
/// Includes **Play**, **Pause**, and optional **Sync** feedback.
class WebPlaybackControls extends StatefulWidget {
  const WebPlaybackControls({
    required this.syncManager,
    super.key,
  });

  final SyncManager syncManager;

  @override
  State<WebPlaybackControls> createState() => _WebPlaybackControlsState();
}

class _WebPlaybackControlsState extends State<WebPlaybackControls> {
  var _isPlaying = false;

  Future<void> _playVideo(BuildContext context) async {
    try {
      await widget.syncManager.playback.play();
      widget.syncManager.start();
      setState(() => _isPlaying = true);
      CoreUtils.showSnackBar(context, 'You started the video.');
    } catch (_) {
      CoreUtils.showSnackBar(context, '❌ Failed to play video.');
    }
  }

  Future<void> _pauseVideo(BuildContext context) async {
    try {
      await widget.syncManager.playback.pause();
      setState(() => _isPlaying = false);
      CoreUtils.showSnackBar(context, 'You paused the video.');
    } catch (_) {
      CoreUtils.showSnackBar(context, '❌ Failed to pause video.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
        color: theme.scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Play',
            onTap: () => _playVideo(context),
            isActive: _isPlaying,
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.pause_rounded,
            label: 'Pause',
            onTap: () => _pauseVideo(context),
            isActive: !_isPlaying,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final color = isActive ? theme.colorScheme.primary : theme.iconTheme.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28, color: color),
          onPressed: onTap,
          tooltip: label,
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
