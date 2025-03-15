import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_email.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late SignInWithEmail useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInWithEmail(repository);
  });

  const testUser = UserEntity.empty();
  const testParams = SignInParams.empty();

  test(
    'given SignInWithEmail '
    'when instantiated '
    'then call [AuthRepository.signInWithEmail] '
    'and return [UserEntity]',
    () async {
      // Arrange
      when(
        () => repository.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => const Right(testUser));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, UserEntity>(testUser));
      verify(
        () => repository.signInWithEmail(testParams.email, testParams.password),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SignInWithEmail '
    'when instantiated '
    'and call [AuthRepository.signInWithEmail] is unsuccessful '
    'then return [SignInFailure]',
    () async {
      // Arrange
      final testFailure = SignInFailure(
        message: 'Invalid credentials',
        statusCode: 'SIGN_IN_ERROR',
      );
      when(
        () => repository.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, UserEntity>(testFailure));
      verify(
        () => repository.signInWithEmail(testParams.email, testParams.password),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
