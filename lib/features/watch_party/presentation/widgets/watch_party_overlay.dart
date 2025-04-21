// lib/features/watch_party/presentation/widgets/watch_party_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';

class WatchPartyOverlay extends StatefulWidget {
  const WatchPartyOverlay({
    required this.onClose,
    required this.onSync,
    required this.onPause,
    required this.onPlay,
    required this.watchPartyId,
    super.key,
  });
  final VoidCallback onClose;
  final VoidCallback onSync;
  final VoidCallback onPause;
  final VoidCallback onPlay;
  final String watchPartyId;

  @override
  State<WatchPartyOverlay> createState() => _WatchPartyOverlayState();
}

class _WatchPartyOverlayState extends State<WatchPartyOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  var _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward(); // Fade in
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _controller.reverse(); // Animate fade out
    widget.onClose(); // Call parent close
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dragOffset.dx,
      top: _dragOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _dragOffset += details.delta;
          });
        },
        child: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              Material(
                elevation: 5,
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: context.width * 0.9,
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                    minHeight: 100,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.black54,
                          child: const Text(
                            'Chat goes here...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        // Native Mode Controls
                        NativePlaybackControls(watchPartyId: widget.watchPartyId),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 50,
                child: GestureDetector(
                  onTap: _handleClose,
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// This is a new widget just for floating overlay controls (Native mode).
class NativePlaybackControls extends StatelessWidget {
  const NativePlaybackControls({required this.watchPartyId, super.key});

  final String watchPartyId;

  void _sendSyncEvent(BuildContext context) {
    context.read<WatchPartyBloc>().add(GetSyncedDataEvent(partyId: watchPartyId));
  }

  void _sendPlayingEvent(BuildContext context) {
    context.read<WatchPartyBloc>().add(
          SyncPlaybackEvent(
            watchPartyId: watchPartyId,
            playbackPosition: 0, // No way to get exact position in Native Mode
          ),
        );
  }

  void _sendPausedEvent(BuildContext context) {
    context.read<WatchPartyBloc>().add(
          SyncPlaybackEvent(
            watchPartyId: watchPartyId,
            playbackPosition: 0, // No way to get exact position in Native Mode
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: () => _sendPlayingEvent(context),
          icon: const Icon(Icons.play_arrow, size: 18),
          label: const Text('I\'m Playing'),
        ),
        ElevatedButton.icon(
          onPressed: () => _sendPausedEvent(context),
          icon: const Icon(Icons.pause, size: 18),
          label: const Text('I Paused'),
        ),
        ElevatedButton.icon(
          onPressed: () => _sendSyncEvent(context),
          icon: const Icon(Icons.sync, size: 18),
          label: const Text('Sync with Host'),
        ),
      ],
    );
  }
}
