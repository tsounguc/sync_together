import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/reject_friend_request.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late RejectFriendRequest useCase;

  final testRequest = FriendRequest.empty();

  setUp(() {
    repository = MockFriendsRepository();
    useCase = RejectFriendRequest(repository);
    registerFallbackValue(testRequest);
  });

  final testFailure = RejectRequestFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given RejectFriendRequest, '
    'when instantiated '
    'then [FriendsRepository.rejectFriendRequest] is called successfully ',
    () async {
      // Arrange
      when(
        () => repository.rejectFriendRequest(
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.rejectFriendRequest(
          request: testRequest,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given RejectFriendRequest, '
    'when [FriendsRepository.rejectFriendRequest] call is unsuccessful '
    'then return [RejectRequestFailure]',
    () async {
      // Arrange
      when(
        () => repository.rejectFriendRequest(
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.rejectFriendRequest(
          request: testRequest,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
