import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/accept_friend_request.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late AcceptFriendRequest useCase;

  final testRequest = FriendRequest.empty();
  setUp(() {
    repository = MockFriendsRepository();
    useCase = AcceptFriendRequest(repository);
    registerFallbackValue(testRequest);
  });

  final testFailure = AcceptRequestFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given AcceptFriendRequest, '
    'when instantiated '
    'then call [FriendsRepository.acceptFriendRequest] successfully ',
    () async {
      // Arrange
      when(
        () => repository.acceptFriendRequest(
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.acceptFriendRequest(
          request: testRequest,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given AcceptFriendRequest, '
    'when instantiated '
    'and [FriendsRepository.acceptFriendRequest] called unsuccessfully '
    'then return [AcceptRequestFailure] ',
    () async {
      // Arrange
      when(
        () => repository.acceptFriendRequest(
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testRequest);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.acceptFriendRequest(
          request: testRequest,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
