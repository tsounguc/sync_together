import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/get_current_user.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late GetCurrentUser useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentUser(repository);
  });
  const testUser = UserEntity.empty();
  test(
    'given GetCurrentUser '
    'when instantiated '
    'then call [AuthRepository.getCurrentUser] '
    'and return a [UserEntity]',
    () async {
      // Arrange
      when(
        () => repository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(testUser));
      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, UserEntity>(testUser));
      verify(
        () => repository.getCurrentUser(),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given GetCurrentUser '
    'when instantiated '
    'and call [AuthRepository.getCurrentUser] is unsuccessful '
    'then return a [GetCurrentUserFailure]',
    () async {
      // Arrange
      final testFailure = GetCurrentUserFailure(
        message: 'Failed to get current user',
        statusCode: 'CURRENT_USER_ERROR',
      );
      when(
        () => repository.getCurrentUser(),
      ).thenAnswer((_) async => Left(testFailure));
      // Act
      final result = await useCase();

      // Assert
      expect(result, Left<Failure, UserEntity>(testFailure));
      verify(
        () => repository.getCurrentUser(),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
