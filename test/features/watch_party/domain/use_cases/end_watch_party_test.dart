import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/end_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late EndWatchParty useCase;
  final testParty = WatchParty.empty();

  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = EndWatchParty(repository);
    registerFallbackValue(testParty);
  });

  final testFailure = EndWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given EndWatchParty, '
    'when instantiated '
    'then call [WatchPartyRepository.endWatchParty] successfully ',
    () async {
      // Arrange
      when(
        () => repository.endWatchParty(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParty.id);

      // Assert
      expect(
        result,
        const Right<Failure, void>(null),
      );
      verify(
        () => repository.endWatchParty(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given EndWatchParty, '
    'when instantiated '
    'and [WatchPartyRepository.endWatchParty] called unsuccessfully '
    'then return [EndWatchPartyFailure] ',
    () async {
      // Arrange
      when(
        () => repository.endWatchParty(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParty.id);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.endWatchParty(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
