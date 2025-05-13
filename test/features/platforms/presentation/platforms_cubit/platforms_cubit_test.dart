import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/use_cases/load_platforms.dart';
import 'package:sync_together/features/platforms/presentation/platforms_cubit/platforms_cubit.dart';

class MockLoadPlatforms extends Mock implements LoadPlatforms {}

void main() {
  late LoadPlatforms loadPlatforms;

  late PlatformsCubit cubit;

  const testPlatform = StreamingPlatform.empty();
  final testFailure = LoadPlatformsFailure(
    message: 'message',
    statusCode: 500,
  );

  setUp(() {
    loadPlatforms = MockLoadPlatforms();

    cubit = PlatformsCubit(loadPlatforms);

    registerFallbackValue(testPlatform);
  });

  tearDown(() {
    cubit.close();
  });

  test(
    'given PlatformsCubit '
    'when cubit is instantiated '
    'then initial state should be [PlatformsInitial]',
    () async {
      // Arrange
      // Act
      // Assert
      expect(cubit.state, PlatformsInitial());
    },
  );

  final testPlatforms = <StreamingPlatform>[];

  group('loadPlatforms - ', () {
    blocTest<PlatformsCubit, PlatformsState>(
      'given ChatCubit '
      'when [PlatformsCubit.fetchPlatforms] is called '
      'then emit [PlatformsLoading, PlatformsLoaded] ',
      build: () {
        when(() => loadPlatforms()).thenAnswer(
          (_) async => Right(testPlatforms),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchPlatforms(),
      expect: () => [
        PlatformsLoading(),
        PlatformsLoaded(testPlatforms),
      ],
      verify: (cubit) {
        verify(
          () => loadPlatforms(),
        ).called(1);
        verifyNoMoreInteractions(loadPlatforms);
      },
    );
    blocTest<PlatformsCubit, PlatformsState>(
      'given PlatformsCubit '
      'when [PlatformsCubit.loadPlatforms] is called '
      'then emit [PlatformsLoading, PlatformsError] ',
      build: () {
        when(() => loadPlatforms()).thenAnswer(
          (_) async => Left(testFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchPlatforms(),
      expect: () => [
        PlatformsLoading(),
        PlatformsError(testFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => loadPlatforms(),
        ).called(1);
        verifyNoMoreInteractions(loadPlatforms);
      },
    );
  });
}
