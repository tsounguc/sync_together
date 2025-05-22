import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/start_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late StartWatchParty useCase;

  final testParty = WatchParty.empty();
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = StartWatchParty(repository);
  });

  final testFailure = StartWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given StartWatchParty, '
    'when initiated '
    'then call [WatchPartyRepository.startParty] successfully ',
    () async {
      // Arrange
      when(
        () => repository.startParty(
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
        () => repository.startParty(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given StartWatchParty, '
    'when instantiated '
    'and [WatchPartyRepository.startParty] called unsuccessfully '
    'then return [StartWatchPartyFailure]',
    () async {
      // Arrange
      when(
        () => repository.startParty(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParty.id);

      // Assert
      expect(
        result,
        Left<Failure, void>(testFailure),
      );
      verify(
        () => repository.startParty(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
