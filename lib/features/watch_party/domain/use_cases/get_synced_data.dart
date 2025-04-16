import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/sync_playback_service.dart';

class GetSyncedData extends StreamUseCaseWithParams<DataMap, String> {
  GetSyncedData(this.service);

  final SyncPlaybackService service;

  @override
  ResultStream<DataMap> call(
    String params,
  ) =>
      service.getSyncedData(roomId: params);
}
