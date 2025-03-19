import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// Creates a new watch party session.
class CreateWatchParty extends UseCaseWithParams<WatchParty, CreateWatchPartyParams> {
  const CreateWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<WatchParty> call(
    CreateWatchPartyParams params,
  ) =>
      repository.createWatchParty(
        hostId: params.hostId,
        videoUrl: params.videoUrl,
        title: params.title
      );
}

/// Parameters required to create a watch party session.
class CreateWatchPartyParams extends Equatable {
  const CreateWatchPartyParams({
    required this.hostId,
    required this.videoUrl,
    required this.title,
  });

  /// The unique ID of the host creating the session.
  final String hostId;

  /// The URL of the video to be watched.
  final String videoUrl;

  /// The title of the movie/show.
  final String title;

  @override
  List<Object?> get props => [hostId, videoUrl, title];
}
