import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/platforms/data/data_sources/platforms_data_source.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';
import 'package:sync_together/features/platforms/data/repositories/platforms_repository_impl.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/repositories/platforms_repository.dart';

class MockPlatformsDataSource extends Mock implements PlatformsDataSource {}

void main() {
  late PlatformsDataSource dataSource;
  late PlatformsRepositoryImpl repositoryImpl;

  setUp(() {
    dataSource = MockPlatformsDataSource();
    repositoryImpl = PlatformsRepositoryImpl(
      dataSource: dataSource,
    );
  });

  test(
    'given PlatformsRepositoryImpl '
    'when instantiated '
    'then instance should be a subclass of [PlatformsRepository]',
    () async {
      // Arrange
      // Act
      // Assert
      expect(repositoryImpl, isA<PlatformsRepository>());
    },
  );

  final testPlatforms = [const StreamingPlatformModel.empty()];
  group('loadPlatforms -', () {
    test(
      'given PlatformsRepositoryImpl, '
      'when [PlatformsDataSource.loadPlatforms] is called '
      'then return [List<StreamingPlatform>]',
      () async {
        // Arrange
        when(
          () => dataSource.loadPlatforms(),
        ).thenAnswer((_) async => testPlatforms);

        // Act
        final result = await repositoryImpl.loadPlatforms();

        // Assert
        expect(
          result,
          Right<Failure, List<StreamingPlatform>>(testPlatforms),
        );
        verify(
          () => dataSource.loadPlatforms(),
        ).called(1);
        verifyNoMoreInteractions(dataSource);
      },
    );

    test(
      'given PlatformsRepositoryImpl, '
      'when [PlatformsDataSource.loadPlatforms] unsuccessful '
      'then return [LoadPlatformsFailure]',
      () async {
        // Arrange
        const testException = LoadPlatformsException(
          message: 'Something went wrong',
          statusCode: '500',
        );
        when(
          () => dataSource.loadPlatforms(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.loadPlatforms();

        // Assert
        expect(
          result,
          Left<Failure, List<StreamingPlatform>>(
            LoadPlatformsFailure.fromException(testException),
          ),
        );
        verify(
          () => dataSource.loadPlatforms(),
        ).called(1);
        verifyNoMoreInteractions(dataSource);
      },
    );
  });
}
