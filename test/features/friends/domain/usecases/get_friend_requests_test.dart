import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/get_friend_requests.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late GetFriendRequests useCase;
  const testUserId = '123';
  setUp(() {
    repository = MockFriendsRepository();
    useCase = GetFriendRequests(repository);
  });

  final testRequests = <FriendRequest>[];
  final testFailure = GetFriendRequestsFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given GetFriendRequests, '
    'when [FriendsRepository.getFriendRequests] is called successfully '
    'then return [List<FriendRequest>] ',
    () async {
      // Arrange
      when(
        () => repository.getFriendRequests(any()),
      ).thenAnswer((_) async => Right(testRequests));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(
        result,
        Right<Failure, List<FriendRequest>>(testRequests),
      );
      verify(
        () => repository.getFriendRequests(testUserId),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given GetFriendRequests, '
    'when [FriendsRepository.getFriendRequests] call is unsuccessful '
    'then return [GetFriendRequestsFailure] ',
    () async {
      // Arrange
      when(
        () => repository.getFriendRequests(any()),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testUserId);

      // Assert
      expect(
        result,
        Left<Failure, List<FriendRequest>>(testFailure),
      );
      verify(
        () => repository.getFriendRequests(
          testUserId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
