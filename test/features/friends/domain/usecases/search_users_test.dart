import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';
import 'package:sync_together/features/friends/domain/use_cases/search_users.dart';

import 'friends_repository.mock.dart';

void main() {
  late FriendsRepository repository;
  late SearchUsers useCase;

  const testQuery = 'John Doe';

  setUp(() {
    repository = MockFriendsRepository();
    useCase = SearchUsers(repository);
  });

  final testUsers = <UserEntity>[];
  final testFailure = SearchUsersFailure(
    message: 'message',
    statusCode: 500,
  );

  test(
    'given SearchUsers, '
    'when instantiated '
    'then call [FriendsRepository.searchUser] successfully',
    () async {
      // Arrange
      when(
        () => repository.searchUsers(
          any(),
        ),
      ).thenAnswer((_) async => Right(testUsers));

      // Act
      final result = await useCase(testQuery);

      // Assert
      expect(
        result,
        Right<Failure, List<UserEntity>>(testUsers),
      );
      verify(
        () => repository.searchUsers(
          testQuery,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SearchUsers, '
    'when [FriendsRepository.searchUser] call is unsuccessful '
    'then return [SearchUsersFailure] ',
    () async {
      // Arrange
      when(
        () => repository.searchUsers(
          any(),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testQuery);

      // Assert
      expect(
        result,
        Left<Failure, List<UserEntity>>(testFailure),
      );
      verify(
        () => repository.searchUsers(
          testQuery,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
