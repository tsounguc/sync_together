import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/utils/native_launcher.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/watch_party_overlay.dart';

class WatchPartyNativeAppMode extends StatefulWidget {
  const WatchPartyNativeAppMode({
    required this.watchParty,
    required this.platform,
    super.key,
  });
  final WatchParty watchParty;
  final StreamingPlatform platform;

  @override
  State<WatchPartyNativeAppMode> createState() => _WatchPartyNativeAppModeState();
}

class _WatchPartyNativeAppModeState extends State<WatchPartyNativeAppMode> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _overlayKey = GlobalKey();

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => WatchPartyOverlay(
        watchPartyId: widget.watchParty.id,
        onClose: () {},
        onSync: () {},
        onPause: () {},
        onPlay: () {},
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Party (${widget.platform.name})'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final isInstalled = await NativeAppLauncher.isAppInstalled(
              widget.platform.packageName ?? '',
            );

            final package = widget.platform.packageName ?? '';
            final deepLink = widget.platform.deeplinkUrl ?? '';
            final playStoreUrl = widget.platform.playStoreUrl ?? widget.platform.defaultUrl;

            debugPrint('Is Netflix Installed: $isInstalled');

            final isGranted = await FlutterOverlayWindow.isPermissionGranted();
            if (!isGranted) {
              final granted = await FlutterOverlayWindow.requestPermission() ?? false;
              if (!granted) {
                CoreUtils.showSnackBar(
                  context,
                  'Overlay permission not granted.',
                );

                return;
              }
            }

            await FlutterOverlayWindow.showOverlay(
              height: 450,
              width: 800,
              alignment: OverlayAlignment.centerRight,
              // enableDrag: true,
              // flag: OverlayFlag.defaultFlag,
              // overlayTitle: 'SyncTogether Overlay',
              // overlayContent: 'Controlling sync...',
            );

            final overlayIsActive = await FlutterOverlayWindow.isActive();
            if (!overlayIsActive) {
              try {
                if (deepLink.isNotEmpty) {
                  await NativeAppLauncher.launchUriScheme(deepLink, package);
                  debugPrint('Launching ${widget.platform.name} deep link...');
                } else {
                  // await NativeAppLauncher.openApp(package);
                  // debugPrint('Launching ${widget.platform.name} with android intent...');
                  var storeUrl = Platform.isAndroid ? widget.platform.playStoreUrl : widget.platform.appstoreUrl;
                  await NativeAppLauncher.launchUri(storeUrl ?? '');
                }
              } catch (e) {
                debugPrint('Error launching installed app: $e');
                var storeUrl = Platform.isAndroid ? widget.platform.playStoreUrl : widget.platform.appstoreUrl;
                await NativeAppLauncher.launchUri(storeUrl ?? '');
              }
              // } else {
              // debugPrint('Launching fallback Netflix web page...');
              // var storeUrl = Platform.isAndroid ? widget.platform.playStoreUrl : widget.platform.appstoreUrl;
              // await NativeAppLauncher.launchUri(storeUrl ?? '');
              // if (!context.mounted) return;
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Netflix app not installed. Opened web instead.')),
              // );
              // }
            }
          },
          icon: const Icon(Icons.tv),
          label: const Text('Open App + Enter PiP'),
        ),
      ),
      // body: Column(
      //   children: [
      //     // Video Player
      //     if (_controller.value.isInitialized)
      //       AspectRatio(
      //         aspectRatio: _controller.value.aspectRatio,
      //         child: VideoPlayer(_controller),
      //       )
      //     else
      //       const Center(child: CircularProgressIndicator()),
      //
      //     // Playback Controls
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         IconButton(
      //           icon: Icon(
      //             _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //           ),
      //           onPressed: () {
      //             setState(() {
      //               _controller.value.isPlaying ? _controller.pause() : _controller.play();
      //             });
      //           },
      //         ),
      //         IconButton(
      //           icon: const Icon(Icons.sync),
      //           onPressed: _syncPlayback,
      //         ),
      //       ],
      //     ),
      //
      //     // Sync Status Indicator
      //     if (_isSyncing)
      //       const Text(
      //         'Syncing playback...',
      //         style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      //       ),
      //   ],
      // ),
    );
  }
}
