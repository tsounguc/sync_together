import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/playback_repository.dart';

/// Syncs video playback across participants in a watch party.
class SyncPlayback extends UseCaseWithParams<void, SyncPlaybackParams> {
  const SyncPlayback(this.repository);

  final PlaybackRepository repository;

  @override
  ResultVoid call(SyncPlaybackParams params) => repository.sendSyncData(
        roomId: params.partyId,
        playbackPosition: params.playbackPosition,
        isPlaying: params.isPlaying,
      );
}

/// Parameters for syncing playback position.
class SyncPlaybackParams extends Equatable {
  const SyncPlaybackParams({
    required this.partyId,
    required this.playbackPosition,
    required this.isPlaying,
  });

  /// Unique watch party ID.
  final String partyId;

  /// The current playback position (in seconds).
  final double playbackPosition;

  /// Flag for play or pause status
  final bool isPlaying;

  @override
  List<Object?> get props => [partyId, playbackPosition, isPlaying];
}
