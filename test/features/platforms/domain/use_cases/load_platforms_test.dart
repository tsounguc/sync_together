import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/repositories/platforms_repository.dart';
import 'package:sync_together/features/platforms/domain/use_cases/load_platforms.dart';

class MockPlatformsRepository extends Mock implements PlatformsRepository {}

void main() {
  late PlatformsRepository repository;
  late LoadPlatforms useCase;

  setUp(() {
    repository = MockPlatformsRepository();
    useCase = LoadPlatforms(repository);
  });

  final testPlatforms = [
    const StreamingPlatform(
      name: 'Netflix',
      logoPath: 'assets/logos/netflix_logo.png',
      isDRMProtected: true,
      defaultUrl: 'https://www.netflix.com',
    ),
    const StreamingPlatform(
      name: 'YouTube',
      logoPath: 'assets/logos/yt_logo_dark.png',
      isDRMProtected: false,
      defaultUrl: 'https://www.youtube.com',
    ),
  ];

  final testFailure = LoadPlatformsFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given LoadPlatforms, '
    'when instantiated '
    'then call [PlatformsRepository.loadPlatforms] '
    'and return [List<StreamingPlatform>]',
    () async {
      // Arrange
      when(
        () => repository.loadPlatforms(),
      ).thenAnswer((_) async => Right(testPlatforms));

      // Act
      final result = await useCase();

      // Assert
      expect(
        result,
        Right<Failure, List<StreamingPlatform>>(testPlatforms),
      );
      verify(
        () => repository.loadPlatforms(),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given LoadPlatforms, '
    'when instantiated '
    'and call [PlatformsRepository.loadPlatforms] is unsuccessful '
    'and return [LoadPlatformFailure]',
    () async {
      // Arrange
      when(
        () => repository.loadPlatforms(),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(
        result,
        Left<Failure, List<StreamingPlatform>>(testFailure),
      );
      verify(
        () => repository.loadPlatforms(),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
