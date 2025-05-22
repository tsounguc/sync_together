import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **Use Case: Create watch party**
///
/// Calls the [WatchPartyRepository] to create a new watch party.
class CreateWatchParty extends UseCaseWithParams<WatchParty, WatchPartyModel> {
  const CreateWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<WatchParty> call(
    WatchParty params,
  ) =>
      repository.createWatchParty(
        party: params,
      );
}
