import 'package:sync_together/core/utils/type_defs.dart';

abstract class PlaybackRepository {
  /// Send the video playback position.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultVoid sendSyncData({
    required String roomId,
    required double playbackPosition,
    required bool isPlaying,
  });

  /// Get the updated video playback position .
  ///
  /// - **Success:** Returns Map.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultStream<DataMap> getSyncedData({
    required String roomId,
  });
}
