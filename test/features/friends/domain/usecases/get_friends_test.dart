import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/get_friends.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late GetFriends useCase;
  const testUserId = '123';

  setUp(() {
    repository = MockFriendsRepository();
    useCase = GetFriends(repository);
  });

  final testFriends = <Friend>[];
  final testFailure = GetFriendsFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given GetFriends, '
    'when instantiate '
    'then call [FriendsRepository.getFriends] successfully',
    () async {
      // Arrange
      when(
        () => repository.getFriends(any()),
      ).thenAnswer((_) async => Right(testFriends));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(result, Right<Failure, List<Friend>>(testFriends));
      verify(
        () => repository.getFriends(testUserId),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given GetFriends, '
    'when [FriendsRepository.getFriends] call is unsuccessful '
    'then return [GetFriendsFailure]',
    () async {
      // Arrange
      when(
        () => repository.getFriends(any()),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(
        result,
        Left<Failure, List<Friend>>(testFailure),
      );
      verify(
        () => repository.getFriends(testUserId),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
