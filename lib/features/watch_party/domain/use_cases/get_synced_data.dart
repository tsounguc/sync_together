import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class GetSyncedData extends StreamUseCaseWithParams<DataMap, String> {
  GetSyncedData(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultStream<DataMap> call(
    String params,
  ) =>
      repository.getSyncedData(partyId: params);
}
