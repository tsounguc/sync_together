import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// Syncs video playback across participants in a watch party.
class SyncPlayback extends UseCaseWithParams<void, SyncPlaybackParams> {
  const SyncPlayback(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<void> call(SyncPlaybackParams params) => repository.syncPlayback(
        partyId: params.partyId,
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
