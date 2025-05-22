import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **Use Case: End a watch party**
///
/// Calls the [WatchPartyRepository] to end the watch party.
class EndWatchParty extends UseCaseWithParams<void, String> {
  EndWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<void> call(
    String params,
  ) =>
      repository.endWatchParty(partyId: params);
}
