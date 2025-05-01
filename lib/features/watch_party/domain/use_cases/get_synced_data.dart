import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/playback_repository.dart';

class GetSyncedData extends StreamUseCaseWithParams<DataMap, String> {
  GetSyncedData(this.service);

  final PlaybackRepository service;

  @override
  ResultStream<DataMap> call(
    String params,
  ) =>
      service.getSyncedData(roomId: params);
}
