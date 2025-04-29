import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/utils/native_launcher.dart';

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
  @override
  void initState() {
    super.initState();
    _launchStreamingApp();
  }

  Future<void> _launchStreamingApp() async {
    final isInstalled = await NativeAppLauncher.isAppInstalled(widget.platform.packageName ?? '');

    final package = widget.platform.packageName ?? '';
    final deepLink = widget.platform.deeplinkUrl ?? '';
    final storeUrl = Platform.isAndroid ? widget.platform.playStoreUrl : widget.platform.appstoreUrl;

    // Ensure overlay permissions
    final isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (!isGranted) {
      final granted = await FlutterOverlayWindow.requestPermission() ?? false;
      if (!granted) {
        CoreUtils.showSnackBar(context, 'Overlay permission not granted.');
        Navigator.of(context).pop();
        return;
      }
    }

    // Show floating overlay window
    await FlutterOverlayWindow.showOverlay(
      // height: 1500,
      // width: 800,
      alignment: OverlayAlignment.centerRight,
      enableDrag: true,
      // enableKeyboard: true,
    );

    final overlayIsActive = await FlutterOverlayWindow.isActive();

    if (!overlayIsActive) {
      CoreUtils.showSnackBar(context, 'Overlay failed to open.');
      Navigator.of(context).pop();
      return;
    }

    try {
      if (isInstalled) {
        if (deepLink.isNotEmpty) {
          await NativeAppLauncher.launchUriScheme(deepLink, package);
          debugPrint('launchUriScheme deepLink: $deepLink');
        } else {
          await NativeAppLauncher.openApp(package);
          debugPrint('openApp: $package');
        }
      } else {
        // App not installed, fallback to store page
        if (storeUrl != null && storeUrl.isNotEmpty) {
          await NativeAppLauncher.launchUri(storeUrl);
          debugPrint('launchUri: $storeUrl');
        } else {
          debugPrint('launchUri not working: $storeUrl');
          CoreUtils.showSnackBar(context, 'Cannot open app or store.');
        }
      }
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Error launching app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Launching Streaming App...'),
      ),
    );
  }
}
