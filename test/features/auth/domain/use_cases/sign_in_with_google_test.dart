import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_google.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late SignInWithGoogle useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInWithGoogle(repository);
  });

  const testUser = UserEntity.empty();
  test(
    'given SignInWithGoogle '
    'when instantiated '
    'then call [AuthRepository.signInWithGoogle] '
    'and return [UserEntity] ',
    () async {
      // Arrange
      when(
        () => repository.signInWithGoogle(),
      ).thenAnswer((_) async => const Right(testUser));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, UserEntity>(testUser));
      verify(() => repository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
  test(
    'given SignInWithGoogle '
    'when instantiated '
    'and call [AuthRepository.signInWithGoogle] is unsuccessful '
    'and return [SignInFailure] ',
    () async {
      // Arrange
      final testFailure = SignInFailure(
        message: 'Google sign-in failed',
        statusCode: 'GOOGLE_SIGN_IN_ERROR',
      );
      when(
        () => repository.signInWithGoogle(),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Left<Failure, UserEntity>(testFailure));
      verify(() => repository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
