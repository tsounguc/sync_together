import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_party_start.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late ListenToPartyStart useCase;

  final testParty = WatchParty.empty();
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = ListenToPartyStart(repository);
  });

  final testFailure = ListenToPartyStartFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given ListenToParticipants, '
    'when initiated '
    'then call [WatchPartyRepository.listenToParticipants] successfully ',
    () async {
      // Arrange
      when(
        () => repository.listenToPartyStart(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) => Stream.value(Right(testParty.hasStarted)));

      // Act
      final result = useCase(testParty.id);

      // Assert
      expect(
        result,
        emits(
          Right<Failure, bool>(testParty.hasStarted),
        ),
      );
      verify(
        () => repository.listenToPartyStart(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given ListenToParticipants, '
    'when initiated '
    'and [WatchPartyRepository.listenToPartyStart] called unsuccessfully '
    'then return [ListenToPartyStartFailure]',
    () async {
      // Arrange
      when(
        () => repository.listenToPartyStart(
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
        () => repository.listenToPartyStart(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
