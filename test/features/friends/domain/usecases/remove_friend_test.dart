import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/remove_friend.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late RemoveFriend useCase;

  const testParams = RemoveFriendParams.empty();

  setUp(() {
    repository = MockFriendsRepository();
    useCase = RemoveFriend(repository);
  });

  final testFailure = RemoveFriendFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given RemoveFriend, '
    'when instantiated '
    'then [FriendsRepository.removeFriend] is called successfully',
    () async {
      // Arrange
      when(
        () => repository.removeFriend(
          senderId: any(named: 'senderId'),
          receiverId: any(named: 'receiverId'),
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
        () => repository.removeFriend(
          senderId: testParams.senderId,
          receiverId: testParams.receiverId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given RemoveFriend, '
    'when [FriendsRepository.removeFriend] call is unsuccessful '
    'then return [RemoveFriendFailure]',
    () async {
      // Arrange
      when(
        () => repository.removeFriend(
          senderId: any(named: 'senderId'),
          receiverId: any(named: 'receiverId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(
        result,
        Left<Failure, void>(testFailure),
      );
      verify(
        () => repository.removeFriend(
          senderId: testParams.senderId,
          receiverId: testParams.receiverId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
