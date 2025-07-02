import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlaybackController {
  PlaybackController({
    required this.controller,
    required this.platform,
  });

  final WebViewController controller;
  final StreamingPlatform platform;

  Future<void> play() async {
    await controller.runJavaScript(platform.playScript);
  }

  Future<void> pause() async {
    await controller.runJavaScript(platform.pauseScript);
  }

  Future<void> seek(double seconds) async {
    await controller.runJavaScript(
      "document.querySelector('video').currentTime = $seconds;",
    );
  }

  Future<bool> isPlaying() async {
    final result = await controller.runJavaScriptReturningResult(
      platform.pauseScript.replaceAll('.pause()', '.paused === false'),
    );
    return result.toString() == 'true';
  }

  Future<double> getCurrentTime(String currentTimeScript) async {
    final result =
        await controller.runJavaScriptReturningResult(currentTimeScript);
    return double.tryParse(result.toString()) ?? 0;
  }

  Future<bool> hasVideoTag() async {
    final result = await controller.runJavaScriptReturningResult(
      "document.querySelector('video') !== null",
    );
    return result.toString() == 'true';
  }
}
