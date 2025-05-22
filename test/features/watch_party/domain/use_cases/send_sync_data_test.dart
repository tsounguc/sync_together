import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/send_sync_data.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late SendSyncData useCase;

  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = SendSyncData(repository);
  });

  const testParams = SendSyncDataParams.empty();
  final testFailure = SendSyncDataFailure(
    message: 'message',
    statusCode: 500,
  );
  test(
    'given SendSyncData, '
    'when initiated '
    'then call [WatchPartyRepository.sendSyncData] successfully ',
    () async {
      // Arrange
      when(
        () => repository.sendSyncData(
          partyId: any(named: 'partyId'),
          playbackPosition: any(named: 'playbackPosition'),
          isPlaying: any(named: 'isPlaying'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.sendSyncData(
          partyId: testParams.partyId,
          playbackPosition: testParams.playbackPosition,
          isPlaying: testParams.isPlaying,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given SendSyncData, '
    'when initiated '
    'and [WatchPartyRepository.sendSyncData] called unsuccessfully '
    'then return [SendSyncDataFailure]',
    () async {
      // Arrange
      when(
        () => repository.sendSyncData(
          partyId: any(named: 'partyId'),
          playbackPosition: any(named: 'playbackPosition'),
          isPlaying: any(named: 'isPlaying'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.sendSyncData(
          partyId: testParams.partyId,
          playbackPosition: testParams.playbackPosition,
          isPlaying: testParams.isPlaying,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
