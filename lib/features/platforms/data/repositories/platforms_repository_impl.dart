import 'package:dartz/dartz.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/data/data_sources/platforms_data_source.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/repositories/platforms_repository.dart';

class PlatformsRepositoryImpl implements PlatformsRepository {
  PlatformsRepositoryImpl({required this.dataSource});

  final PlatformsDataSource dataSource;
  @override
  ResultFuture<List<StreamingPlatform>> loadPlatforms() async {
    try {
      final result = await dataSource.loadPlatforms();
      return Right(result);
    } on LoadPlatformsException catch (e) {
      return Left(LoadPlatformsFailure.fromException(e));
    }
  }
}
