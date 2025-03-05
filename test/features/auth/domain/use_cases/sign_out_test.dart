import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late SignOut useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = SignOut(repository);
  });

  test(
    'given SignOut '
    'when instantiated '
    'then call [AuthRepository.signOut] '
    'and return [void] ',
    () async {
      // Arrange
      when(
        () => repository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(() => repository.signOut()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SignOut '
    'when instantiated '
    'and call [AuthRepository.signOut] is unsuccessful '
    'then return [SignOutFailure] ',
    () async {
      // Arrange
      final testFailure = SignOutFailure(
        message: 'Sign-out failed',
        statusCode: 'SIGN_OUT_ERROR',
      );
      when(
        () => repository.signOut(),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = useCase();

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(() => repository.signOut()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
