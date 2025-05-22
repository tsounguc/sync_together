import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/update_video_url.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late UpdateVideoUrl useCase;

  const testParams = UpdateVideoUrlParams.empty();
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = UpdateVideoUrl(repository);
  });

  final testFailure = UpdateUserFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given UpdateVideoUrl, '
    'when initiated '
    'then call [WatchPartyRepository.updateVideoUrl] successfully ',
    () async {
      // Arrange
      when(
        () => repository.updateVideoUrl(
          partyId: any(named: 'partyId'),
          newUrl: any(named: 'newUrl'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.updateVideoUrl(
          partyId: testParams.partyId,
          newUrl: testParams.newUrl,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given UpdateVideoUrl, '
    'when initiated '
    'and [WatchPartyRepository.updateVideoUrl] called unsuccessfully '
    'then return [UpdateVideoUrlFailure]',
    () async {
      // Arrange
      when(
        () => repository.updateVideoUrl(
          partyId: any(named: 'partyId'),
          newUrl: any(named: 'newUrl'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.updateVideoUrl(
          partyId: testParams.partyId,
          newUrl: testParams.newUrl,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
