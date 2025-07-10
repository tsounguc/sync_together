import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/playback_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPlaybackController implements PlaybackController {
  WebviewPlaybackController({
    required this.controller,
    required this.platform,
  });

  final WebViewController controller;
  final StreamingPlatform platform;

  @override
  Future<void> play() async {
    await controller.runJavaScript(platform.playScript);
  }

  @override
  Future<void> pause() async {
    await controller.runJavaScript(platform.pauseScript);
  }

  @override
  Future<void> seek(double seconds) async {
    await controller.runJavaScript(
      "document.querySelector('video').currentTime = $seconds;",
    );
  }

  @override
  Future<bool> isPlaying() async {
    final result = await controller.runJavaScriptReturningResult(
      platform.pauseScript.replaceAll('.pause()', '.paused === false'),
    );
    return result.toString() == 'true';
  }

  @override
  Future<double> getCurrentTime([String? currentTimeScript]) async {
    final result =
        await controller.runJavaScriptReturningResult(currentTimeScript!);
    return double.tryParse(result.toString()) ?? 0;
  }

  @override
  Future<bool> hasVideoTag() async {
    final result = await controller.runJavaScriptReturningResult(
      "document.querySelector('video') !== null",
    );
    return result.toString() == 'true';
  }

  @override
  Future<void> disableControls() async {
    const js = '''
      var video = document.querySelector('video');
      if (video) {
        video.removeAttribute('controls');
        video.style.pointerEvents = 'none';
        video.muted = false;
        video.volume = 1.0;
      }
    ''';
    await controller.runJavaScript(js);
  }
}
