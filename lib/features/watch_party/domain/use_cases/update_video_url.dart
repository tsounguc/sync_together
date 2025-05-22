import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **Use Case: Update Video url in watch party**
///
/// Calls the [WatchPartyRepository] to update video url.
class UpdateVideoUrl extends UseCaseWithParams<void, UpdateVideoUrlParams> {
  const UpdateVideoUrl(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultVoid call(UpdateVideoUrlParams params) {
    return repository.updateVideoUrl(
      partyId: params.partyId,
      newUrl: params.newUrl,
    );
  }
}

/// **Parameters for updating video url if video changed in watch party**
///
/// Includes a partyId and the newUrl.
class UpdateVideoUrlParams extends Equatable {
  const UpdateVideoUrlParams({
    required this.partyId,
    required this.newUrl,
  });

  const UpdateVideoUrlParams.empty()
      : partyId = '',
        newUrl = '';

  /// The unique ID of the watch party session.
  final String partyId;

  /// new updated url
  final String newUrl;

  @override
  List<Object> get props => [partyId, newUrl];
}
