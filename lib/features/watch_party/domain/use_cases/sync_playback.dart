import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/sync_playback_service.dart';

/// Syncs video playback across participants in a watch party.
class SyncPlayback extends UseCaseWithParams<void, SyncPlaybackParams> {
  const SyncPlayback(this.service);

  final SyncPlaybackService service;

  @override
  ResultVoid call(SyncPlaybackParams params) => service.sendSyncData(
        roomId: params.partyId,
        playbackPosition: params.playbackPosition,
      );
}

/// Parameters for syncing playback position.
class SyncPlaybackParams extends Equatable {
  const SyncPlaybackParams({
    required this.partyId,
    required this.playbackPosition,
  });

  /// Unique watch party ID.
  final String partyId;

  /// The current playback position (in seconds).
  final double playbackPosition;

  @override
  List<Object?> get props => [partyId, playbackPosition];
}
