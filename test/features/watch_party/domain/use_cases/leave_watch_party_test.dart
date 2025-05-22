import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/leave_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late LeaveWatchParty useCase;
  const testParams = LeaveWatchPartyParams.empty();

  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = LeaveWatchParty(repository);
  });

  final testFailure = LeaveWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given LeaveWatchParty, '
    'when instantiated '
    'then call [WatchPartyRepository.leaveWatchParty] successfully',
    () async {
      // Arrange
      when(
        () => repository.leaveWatchParty(
          userId: any(named: 'userId'),
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(
        result,
        const Right<Failure, void>(null),
      );
      verify(
        () => repository.leaveWatchParty(
          userId: testParams.userId,
          partyId: testParams.partyId,
        ),
      ).called(1);
    },
  );

  test(
    'given LeaveWatchParty '
    'when instantiated '
    'and [WatchPartyRepository.leaveWatchParty] called unsuccessfully '
    'then return [LeaveWatchPartyFailure]',
    () async {
      // Arrange
      when(
        () => repository.leaveWatchParty(
          userId: any(named: 'userId'),
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
    },
  );
}
