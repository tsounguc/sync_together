import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_participants.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late ListenToParticipants useCase;

  final testParty = WatchParty.empty();
  final testResponse = <String>[];
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = ListenToParticipants(repository);
  });

  final testFailure = ListenToParticipantsFailure(
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
        () => repository.listenToParticipants(
          partyId: any(named: 'partyId'),
        ),
      ).thenAnswer((_) => Stream.value(Right(testResponse)));

      // Act
      final result = useCase(testParty.id);

      // Assert
      expect(
        result,
        emits(
          Right<Failure, List<String>>(testResponse),
        ),
      );
      verify(
        () => repository.listenToParticipants(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given ListenToParticipants, '
    'when initiated '
    'and [WatchPartyRepository.listenToParticipants] called unsuccessfully '
    'then return [ListenToParticipantsFailure]',
    () async {
      // Arrange
      when(
        () => repository.listenToParticipants(
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
        () => repository.listenToParticipants(
          partyId: testParty.id,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
