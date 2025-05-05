import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repositoryImpl;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    repositoryImpl = AuthRepositoryImpl(remoteDataSource);
    registerFallbackValue(UpdateUserAction.email);
  });

  const name = 'test name';
  const email = 'test@example.com';
  const password = 'password123';
  final testUserModel = const UserModel.empty().copyWith(email: email);

  test(
    'given AuthRepositoryImpl '
    'when instantiated '
    'then instance should be a subclass of [AuthRepository]',
    () async {
      // Arrange
      // Act
      // Assert
      expect(repositoryImpl, isA<AuthRepository>());
    },
  );

  group('signUpWithEmail - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.signUpWithEmail] is called '
      'then return [UserEntity]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.signUpWithEmail(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repositoryImpl.signUpWithEmail(
          name,
          email,
          password,
        );

        // Assert
        expect(result, Right<Failure, UserEntity>(testUserModel));
        verify(
          () => remoteDataSource.signUpWithEmail(
            name: name,
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.signUpWithEmail] unsuccessful '
      'then return [SignUpFailure]',
      () async {
        // Arrange
        const testException = SignUpException(
          message: 'Sign up failed',
          statusCode: 'SIGN_UP_ERROR',
        );
        when(
          () => remoteDataSource.signUpWithEmail(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.signUpWithEmail(
          name,
          email,
          password,
        );

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(SignUpFailure.fromException(testException)),
        );
        verify(
          () => remoteDataSource.signUpWithEmail(
            name: name,
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('signInWithEmail - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.signInWithEmail] is called '
      'then return [UserEntity]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repositoryImpl.signInWithEmail(email, password);

        // Assert
        expect(result, Right<Failure, UserEntity>(testUserModel));
        verify(
          () => remoteDataSource.signInWithEmail(
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.signInWithEmail] unsuccessful '
      'then return [SignInFailure]',
      () async {
        // Arrange
        const testException = SignInException(
          message: 'Sign in failed',
          statusCode: 'SIGN_IN_ERROR',
        );
        when(
          () => remoteDataSource.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.signInWithEmail(email, password);

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(SignInFailure.fromException(testException)),
        );
        verify(
          () => remoteDataSource.signInWithEmail(
            email: email,
            password: password,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('signInWithGoogle - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.signInWithGoogle] is called '
      'then return [UserEntity]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.signInWithGoogle(),
        ).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repositoryImpl.signInWithGoogle();

        // Assert
        expect(result, Right<Failure, UserEntity>(testUserModel));
        verify(
          () => remoteDataSource.signInWithGoogle(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.signInWithGoogle] unsuccessful '
      'then return [SignInFailure]',
      () async {
        // Arrange
        const testException = SignInException(
          message: 'Sign in failed',
          statusCode: 'SIGN_IN_ERROR',
        );
        when(
          () => remoteDataSource.signInWithGoogle(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.signInWithGoogle();

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(
            SignInFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.signInWithGoogle(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('signInAnonymously - ', () {
    const testAnonymousUser = UserModel.empty();
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.signInAnonymously] is called '
      'then return [UserEntity]',
      () async {
        // Arrange

        when(
          () => remoteDataSource.signInAnonymously(),
        ).thenAnswer((_) async => testAnonymousUser);

        // Act
        final result = await repositoryImpl.signInAnonymously();

        // Assert
        expect(
          result,
          const Right<Failure, UserEntity>(testAnonymousUser),
        );
        verify(
          () => remoteDataSource.signInAnonymously(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.signInAnonymously] unsuccessful '
      'then return [SignInFailure]',
      () async {
        // Arrange
        const testException = SignInException(
          message: 'Sign in failed',
          statusCode: 'SIGN_IN_ERROR',
        );
        when(
          () => remoteDataSource.signInAnonymously(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.signInAnonymously();

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(
            SignInFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.signInAnonymously(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('signOut - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.signOut] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.signOut(),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.signOut();

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.signOut(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.signOut] unsuccessful '
      'then return [SignOutFailure]',
      () async {
        // Arrange
        const testException = SignOutException(
          message: 'Sign out failed',
          statusCode: 'SIGN_OUT_ERROR',
        );
        when(
          () => remoteDataSource.signOut(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.signOut();

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(
            SignOutFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.signOut(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getCurrentUser - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.getCurrentUser] is called '
      'then return [UserEntity?]',
      () async {
        when(
          () => remoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => testUserModel);

        // Act
        final result = await repositoryImpl.getCurrentUser();

        // Assert
        expect(result, Right<Failure, UserEntity>(testUserModel));
        verify(
          () => remoteDataSource.getCurrentUser(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'and call [AuthRemoteDataSource.getCurrentUser] unsuccessful '
      'then return [GetCurrentUserFailure]',
      () async {
        // Arrange
        const testException = GetCurrentUserException(
          message: 'Failed to get current user',
          statusCode: 'CURRENT_USER_ERROR',
        );
        // Arrange
        when(
          () => remoteDataSource.getCurrentUser(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.getCurrentUser();

        // Assert
        expect(
          result,
          Left<Failure, UserEntity>(
            GetCurrentUserFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.getCurrentUser(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('forgotPassword - ', () {
    test(
      'given AuthRepositoryImpl, '
      'when [AuthRemoteDataSource.forgotPassword] is called '
      'then complete call to remote data source successfully ',
      () async {
        // Arrange
        when(
          () => remoteDataSource.forgotPassword(
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.forgotPassword(
          testUserModel.email!,
        );

        // Assert
        expect(
          result,
          const Right<Failure, void>(null),
        );
        verify(
          () => remoteDataSource.forgotPassword(
            email: testUserModel.email!,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'when call [AuthRemoteDataSource.forgotPassword] unsuccessful '
      'then return [ForgotPasswordFailure] ',
      () async {
        // Arrange
        const testException = ForgotPasswordException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.forgotPassword(
            email: any(named: 'email'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.forgotPassword(
          testUserModel.email!,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            ForgotPasswordFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.forgotPassword(
            email: testUserModel.email!,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('updateUserProfile - ', () {
    test(
      'given AutRepositoryImpl, '
      'when [AuthRemoteDataSource.updateUserProfile] is called '
      'then complete call to remote data source successfully ',
      () async {
        // Arrange
        when(
          () => remoteDataSource.updateUserProfile(
            action: any(named: 'action'),
            userData: any<dynamic>(named: 'userData'),
          ),
        ).thenAnswer((_) => Future.value());
        // Act
        final result = await repositoryImpl.updateUserProfile(
          action: UpdateUserAction.email,
          userData: testUserModel.email,
        );

        // Assert
        expect(
          result,
          const Right<Failure, void>(null),
        );
        verify(
          () => remoteDataSource.updateUserProfile(
            action: UpdateUserAction.email,
            userData: testUserModel.email,
          ),
        );
      },
    );

    test(
      'given AuthRepositoryImpl, '
      'when call [AuthRemoteDataSource.updateUserProfile] unsuccessful '
      'then return [UpdateUserFailure] ',
      () async {
        // Arrange
        const testException = UpdateUserException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.updateUserProfile(
            action: any(named: 'action'),
            userData: any<dynamic>(named: 'userData'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.updateUserProfile(
          action: UpdateUserAction.email,
          userData: testUserModel.email,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            UpdateUserFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.updateUserProfile(
            action: UpdateUserAction.email,
            userData: testUserModel.email,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
}
