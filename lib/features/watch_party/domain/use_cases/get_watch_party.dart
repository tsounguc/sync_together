import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// Retrieves an active watch party session.
class GetWatchParty extends UseCaseWithParams<WatchParty, String> {
  const GetWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<WatchParty> call(
    String params,
  ) =>
      repository.getWatchParty(params);
}
