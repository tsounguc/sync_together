import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **UseCase: Listen to party existence (returns `false` if deleted)**
class ListenToPartyExistence extends StreamUseCaseWithParams<bool, String> {
  ListenToPartyExistence(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultStream<bool> call(String partyId) {
    return repository.listenToPartyExistence(partyId: partyId);
  }
}
