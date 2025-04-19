import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class WatchStartStatus extends StreamUseCaseWithParams<bool, String> {
  WatchStartStatus(this.repository);
  final WatchPartyRepository repository;
  @override
  ResultStream<bool> call(
    String params,
  ) =>
      repository.watchStartStatus(partyId: params);
}
