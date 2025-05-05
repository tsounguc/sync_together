import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/forgot_password.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late ForgotPassword useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = ForgotPassword(repository);
  });

  final testFailure = ForgotPasswordFailure(
    message: 'message',
    statusCode: 500,
  );

  const testEmail = 'testEmail';
  test(
    'given ForgotPassword '
    'when instantiated '
    'then call [AuthRepository.forgotPassword] '
    'and return [void]',
    () async {
      // Arrange
      when(
        () => repository.forgotPassword(
          any(),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testEmail);

      // Assert
      expect(
        result,
        const Right<Failure, void>(null),
      );

      verify(
        () => repository.forgotPassword(
          testEmail,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given ForgotPassword '
    'when instantiated '
    'then call [AuthRepository.forgotPassword] '
    'and return [void]',
    () async {
      // Arrange
      when(
        () => repository.forgotPassword(
          any(),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testEmail);

      // Assert
      expect(
        result,
        Left<Failure, void>(testFailure),
      );

      verify(
        () => repository.forgotPassword(
          testEmail,
        ),
      ).called(1);

      verifyNoMoreInteractions(repository);
    },
  );
}
