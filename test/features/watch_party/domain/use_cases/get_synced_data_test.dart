import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_synced_data.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late GetSyncedData useCase;

  final syncedData = {'playbackPosition': 1.0};
  final testParty = WatchParty.empty();
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = GetSyncedData(repository);
  });

  final testFailure = GetSyncedDataFailure(
    message: 'message',
    statusCode: 500,
  );
  test(
    'given GetSyncedData, '
    'when initiated '
    'then call [WatchPartyRepository.getSyncedData] successfully ',
    () async {
      // Arrange
      when(
        () => repository.getSyncedData(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) => Stream.value(Right(syncedData)));

      // Act
      final result = useCase(testParty.id);

      // Assert
      expect(
        result,
        emits(
          Right<Failure, DataMap>(syncedData),
        ),
      );
    },
  );

  test(
    'given GetSyncedData, '
    'when initiated '
    'and [WatchPartyRepository.getSyncedData] called unsuccessfully '
    'then return [GetSyncedDataFailure]',
    () async {
      // Arrange
      when(
        () => repository.getSyncedData(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) => Stream.value(Left(testFailure)));

      // Act
      final result = useCase(testParty.id);

      // Assert
      expect(
        result,
        emits(Left<Failure, List<String>>(testFailure)),
      );
      verify(
        () => repository.getSyncedData(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
