import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/repositories/platforms_repository.dart';

class LoadPlatforms extends UseCase<List<StreamingPlatform>> {
  LoadPlatforms(this.repository);

  final PlatformsRepository repository;

  @override
  ResultFuture<List<StreamingPlatform>> call() => repository.loadPlatforms();
}
