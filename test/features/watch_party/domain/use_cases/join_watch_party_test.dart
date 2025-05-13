import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late JoinWatchParty useCase;

  final testParty = WatchParty.empty();
  final testPartyModel = WatchPartyModel.empty();
  const testParams = JoinWatchPartyParams.empty();

  setUp(
    () {
      repository = MockWatchPartyRepository();
      useCase = JoinWatchParty(repository);
      registerFallbackValue(testParty);
    },
  );

  final testFailure = JoinWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given JoinWatchParty, '
    'when instantiated '
    'then call [WatchPartyRepository.joinWatchParty] successfully ',
    () async {
      // Arrange
      when(
        () => repository.joinWatchParty(
          partyId: any(named: 'partyId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => Right(testParty));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Right<Failure, WatchParty>(testParty));
      verify(
        () => repository.joinWatchParty(
          partyId: testParams.partyId,
          userId: testParams.userId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given JoinWatchParty, '
    'when initiated '
    'and [WatchPartyRepository.joinWatchParty] called unsuccessfully '
    'then return [JoinWatchPartyFailure]',
    () async {
      // Arrange
      when(
        () => repository.joinWatchParty(
          partyId: any(named: 'partyId'),
          userId: any(named: 'userId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, WatchParty>(testFailure));
      verify(
        () => repository.joinWatchParty(
          partyId: testParams.partyId,
          userId: testParams.userId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
