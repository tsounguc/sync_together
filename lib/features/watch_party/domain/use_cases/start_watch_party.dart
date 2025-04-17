import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class StartWatchParty extends UseCaseWithParams<void, String> {
  const StartWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultVoid call(String params) => repository.startParty(partyId: params);
}
