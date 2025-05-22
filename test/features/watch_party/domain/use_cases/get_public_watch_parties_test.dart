import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_public_watch_parties.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late GetPublicWatchParties useCase;

  final testParties = <WatchParty>[];

  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = GetPublicWatchParties(repository);
  });
  final testFailure = GetPublicWatchPartiesFailure(
    message: 'message',
    statusCode: 500,
  );
  test(
    'given GetPublicWatchParties, '
    'when initiated '
    'then call [WatchPartyRepository.getPublicWatchParties] successfully',
    () async {
      // Arrange
      when(
        () => repository.getPublicWatchParties(),
      ).thenAnswer((_) async => Right(testParties));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right<Failure, List<WatchParty>>(testParties));
      verify(
        () => repository.getPublicWatchParties(),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
      'given GetPublicWatchParties, '
      'when initiated '
      'and [WatchPartyRepository.getPublicWatchParties] called unsuccessfully '
      'then return [GetWatchPartiesFailure]', () async {
    // Arrange
    when(
      () => repository.getPublicWatchParties(),
    ).thenAnswer((_) async => Left(testFailure));

    // Act
    final result = await useCase();

    // Assert
    expect(
      result,
      Left<Failure, List<WatchParty>>(testFailure),
    );
    verify(() => repository.getPublicWatchParties());
    verifyNoMoreInteractions(repository);
  });
}
