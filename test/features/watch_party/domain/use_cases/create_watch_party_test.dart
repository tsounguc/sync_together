import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';

import 'watch_party_repository.mock.dartt.dart';

void main() {
  late WatchPartyRepository repository;
  late CreateWatchParty useCase;

  final testParty = WatchParty.empty();
  final testPartyModel = WatchPartyModel.empty();
  setUp(() {
    repository = MockWatchPartyRepository();
    useCase = CreateWatchParty(repository);
    registerFallbackValue(testPartyModel);
    registerFallbackValue(testParty);
  });

  final testFailure = CreateWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given CreateWatchParty, '
    'when initiated '
    'then call [WatchPartyRepository.createWatchParty] successfully ',
    () async {
      // Arrange
      when(
        () => repository.createWatchParty(
          party: any(named: 'party'),
        ),
      ).thenAnswer((_) async => Right(testParty));

      // Act
      final result = await useCase(testPartyModel);

      // Assert
      expect(result, Right<Failure, WatchParty>(testParty));
      verify(
        () => repository.createWatchParty(
          party: testPartyModel,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given CreateWatchParty, '
    'when initiated '
    'and [WatchPartyRepository.createWatchParty] called unsuccessfully '
    'then return [CreateWatchPartyFailure]',
    () async {
      // Arrange
      when(
        () => repository.createWatchParty(
          party: any(named: 'party'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testPartyModel);

      // Assert
      expect(result, Left<Failure, WatchParty>(testFailure));
      verify(
        () => repository.createWatchParty(
          party: testPartyModel,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
