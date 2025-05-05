import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/update_user_profile.dart';

import 'auth_repository.mock.dart';

void main() {
  late AuthRepository repository;
  late UpdateUserProfile useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = UpdateUserProfile(repository);
    registerFallbackValue(UpdateUserAction.email);
  });

  const testEmail = 'test email';
  test(
    'given UpdateUserProfile '
    'when instantiated '
    'then call [AuthRepository.updateUserProfile] '
    'and return [void] ',
    () async {
      // Arrange
      when(
        () => repository.updateUserProfile(
          action: any(named: 'action'),
          userData: any<dynamic>(named: 'userData'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        const UpdateUserProfileParams(
          action: UpdateUserAction.email,
          userData: testEmail,
        ),
      );

      // Assert
      expect(
        result,
        const Right<Failure, void>(null),
      );
      verify(
        () => repository.updateUserProfile(
          action: UpdateUserAction.email,
          userData: testEmail,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
