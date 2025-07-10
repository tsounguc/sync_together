import 'dart:async';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/playback_controller.dart';

class GuestSyncHelper {
  final PlaybackController playback;
  final double targetPosition;
  final bool shouldPlay;

  GuestSyncHelper({
    required this.playback,
    required this.targetPosition,
    required this.shouldPlay,
  });

  Future<bool> attemptInitialSync({int maxAttempts = 10}) async {
    for (var i = 0; i < maxAttempts; i++) {
      try {
        if (!await playback.hasVideoTag()) {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          continue;
        }

        if (targetPosition < 1.0) {
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }

        await playback.disableControls();
        await playback.pause();
        await playback.seek(targetPosition);

        if (shouldPlay && await playback.isPlaying()) {
          return true;
        }
        if (shouldPlay && !(await playback.isPlaying())) {
          await playback.play();
          return true;
        }
        if (!shouldPlay && !(await playback.isPlaying())) return true;
      } catch (_) {}

      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    return false;
  }
}
