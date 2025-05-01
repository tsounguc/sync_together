import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

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

class UpdateVideoUrlParams extends Equatable {
  const UpdateVideoUrlParams({required this.partyId, required this.newUrl});

  final String partyId;
  final String newUrl;

  @override
  List<Object> get props => [partyId, newUrl];
}
