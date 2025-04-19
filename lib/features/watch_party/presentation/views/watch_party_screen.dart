// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
// import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
// import 'package:sync_together/features/watch_party/presentation/views/watch_party_native_app_mode.dart';
// import 'package:sync_together/features/watch_party/presentation/views/watch_party_webview.dart';
// import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
// import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';
// import 'package:video_player/video_player.dart';

// class WatchPartyScreen extends StatefulWidget {
//   const WatchPartyScreen({
//     required this.watchParty,
//     super.key,
//   });
//
//   final WatchParty watchParty;
//
//   static const String id = '/watch-party';
//
//   @override
//   State<WatchPartyScreen> createState() => _WatchPartyScreenState();
// }
//
// class _WatchPartyScreenState extends State<WatchPartyScreen> {
//   double _currentPosition = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     // Optionally start listening for updates when the screen loads
//     context.read<WatchPartyBloc>().add(
//           GetSyncedDataEvent(watchPartyId: widget.watchParty.id),
//         );
//   }
//
//   void _updatePosition(double position) {
//     setState(() {
//       _currentPosition = position;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.watchParty.title)),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Watching together!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//
//             // Simulate current position display for now
//             Text('Current Position: ${_currentPosition.toStringAsFixed(1)}s'),
//
//             const Spacer(),
//
//             // Playback Controls
//             PlaybackControls(
//               watchPartyId: widget.watchParty.id,
//               currentPosition: _currentPosition,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WatchPartyScreen extends StatefulWidget {
//   const WatchPartyScreen({
//     required this.watchParty,
//     required this.platform,
//     super.key,
//   });
//
//   final WatchParty watchParty;
//   final StreamingPlatform platform;
//
//   static const String id = '/watch-party';
//
//   @override
//   State<WatchPartyScreen> createState() => _WatchPartyScreenState();
// }
//
// class _WatchPartyScreenState extends State<WatchPartyScreen> {
//   late VideoPlayerController _controller;
//   bool _isSyncing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(Uri.parse(widget.watchParty.videoUrl))
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//
//     // Listen for state changes (for sync updates)
//     context.read<WatchPartyBloc>().stream.listen((state) {
//       if (state is SyncUpdated) {
//         _controller.seekTo(Duration(seconds: state.playbackPosition.toInt()));
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _syncPlayback() {
//     final position = _controller.value.position.inSeconds.toDouble();
//     context.read<WatchPartyBloc>().add(
//           SyncPlaybackEvent(
//             watchPartyId: widget.watchParty.id,
//             playbackPosition: position,
//           ),
//         );
//
//     setState(() {
//       _isSyncing = true;
//     });
//
//     Future.delayed(const Duration(seconds: 2), () {
//       setState(() {
//         _isSyncing = false;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return widget.platform.isDRMProtected
//         ? WatchPartyNativeAppMode(
//             watchParty: widget.watchParty,
//             platform: widget.platform,
//           )
//         : WatchPartyWebView(
//             watchParty: widget.watchParty,
//           );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_native_app_mode.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_webview.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';

class WatchPartyScreen extends StatefulWidget {
  const WatchPartyScreen({
    required this.watchParty,
    required this.platform,
    super.key,
  });

  final WatchParty watchParty;
  final StreamingPlatform platform;

  static const String id = '/watch-party';

  @override
  State<WatchPartyScreen> createState() => _WatchPartyScreenState();
}

class _WatchPartyScreenState extends State<WatchPartyScreen> {
  @override
  void initState() {
    super.initState();

    // Start listening to live playback sync updates
    context.read<WatchPartyBloc>().add(
          GetSyncedDataEvent(partyId: widget.watchParty.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.platform.isDRMProtected
          ? WatchPartyNativeAppMode(
              watchParty: widget.watchParty,
              platform: widget.platform,
            )
          : WatchPartyWebView(
              watchParty: widget.watchParty,
            ),
    );
  }
}
