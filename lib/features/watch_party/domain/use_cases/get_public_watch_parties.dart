import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// Get list of public watch parties.
class GetPublicWatchParties extends UseCase<List<WatchParty>> {
  const GetPublicWatchParties(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<List<WatchParty>> call() => repository.getPublicWatchParties();
}
