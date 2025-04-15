import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

abstract class PlatformsRepository {
  ResultFuture<List<StreamingPlatform>> loadPlatforms();
}
