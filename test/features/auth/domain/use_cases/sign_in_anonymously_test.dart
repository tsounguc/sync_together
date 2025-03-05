import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late SignInAnonymously useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignInAnonymously(repository);
  });

  const testUser = UserEntity.empty();

  test(
    'given SignInAnonymously '
    'when instantiated '
    'then call [AuthRepository.signInAnonymously] '
    'and return [UserEntity]',
    () async {
      // Arrange
      when(() => repository.signInAnonymously()).thenAnswer(
        (_) async => const Right(testUser),
      );

      // Act
      final result = useCase();

      // Assert
      expect(result, const Right<Failure, UserEntity>(testUser));
      verify(() => repository.signInAnonymously()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SignInAnonymously '
    'when instantiated '
    'and call [AuthRepository.signInAnonymously] is unsuccessful '
    'then return [SignInFailure]',
    () async {
      // Arrange
      final testFailure = SignInFailure(
        message: 'Anonymous sign-in failed',
        statusCode: 'ANON_SIGN_IN_ERROR',
      );
      when(
        () => repository.signInAnonymously(),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = useCase();

      // Assert
      expect(result, Left<Failure, UserEntity>(testFailure));
      verify(() => repository.signInAnonymously()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
