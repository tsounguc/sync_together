import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

import 'auth_repository.mock.dart';

void main() {
  late MockAuthRepository repository;
  late SignUpWithEmail useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignUpWithEmail(repository);
  });

  const testUser = UserEntity.empty();
  const testParams = SignUpParams.empty();

  test(
    'given SignUpWithEmail '
    'when instantiated '
    'then call [AuthRepository.signUpWithEmail] '
    'and return [UserEntity] ',
    () async {
      // Arrange
      when(
        () => repository.signUpWithEmail(any(), any()),
      ).thenAnswer((_) async => const Right(testUser));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, UserEntity>(testUser));
      verify(
        () => repository.signUpWithEmail(testParams.email, testParams.password),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SignUpWithEmail '
    'when instantiated '
    'and call [AuthRepository.signUpWithEmail] is unsuccessful '
    'and return [SignUpFailure] ',
    () async {
      // Arrange
      final testFailure = SignUpFailure(
        message: 'Sign up Failed ',
        statusCode: 'SIGN_UP_ERROR',
      );
      when(
        () => repository.signUpWithEmail(any(), any()),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Left<Failure, UserEntity>(testFailure));
      verify(
        () => repository.signUpWithEmail(testParams.email, testParams.password),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
