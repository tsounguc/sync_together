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

                        // Playback Controls
                        PlaybackControls(
                          watchPartyId: widget.watchPartyId,
                          currentPosition: 0.0,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                // left: _dragOffset.dx,
                // top: _dragOffset.dy,
                top: 10,
                right: 50,
                child: GestureDetector(
                  // onPanUpdate: (details) {
                  //   setState(() {
                  //     _dragOffset += Offset(details.delta.dx, details.delta.dy);
                  //   });
                  // },
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
