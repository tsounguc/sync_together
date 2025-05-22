import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late GetWatchParty useCase;

  final testParty = WatchParty.empty();

  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = GetWatchParty(repository);
  });

  final testFailure = GetWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given GetWatchParty, '
    'when initiated '
    'then call [WatchPartyRepository.getWatchParty] successfully ',
    () async {
      // Arrange
      when(
        () => repository.getWatchParty(any()),
      ).thenAnswer((_) async => Right(testParty));

      // Act
      final result = await useCase(testParty.id);

      // Assert
      expect(result, Right<Failure, WatchParty>(testParty));
      verify(() => repository.getWatchParty(testParty.id));
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given GetWatchParty, '
    'when initiated '
    'and [WatchPartyRepository.getWatchParty] called unsuccessfully '
    'then return [GetWatchPartyFailure]',
    () async {
      // Arrange
      when(
        () => repository.getWatchParty(
          any(),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParty.id);

      // Assert
      expect(
        result,
        Left<Failure, WatchParty>(testFailure),
      );
      verify(
        () => repository.getWatchParty(testParty.id),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
