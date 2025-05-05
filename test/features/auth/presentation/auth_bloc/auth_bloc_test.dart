import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/use_cases/forgot_password.dart';
import 'package:sync_together/features/auth/domain/use_cases/get_current_user.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_out.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/update_user_profile.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignInAnonymously extends Mock implements SignInAnonymously {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockUpdateUserProfile extends Mock implements UpdateUserProfile {}

void main() {
  late SignInWithEmail signInWithEmail;
  late SignInWithGoogle signInWithGoogle;
  late SignInAnonymously signInAnonymously;
  late SignUpWithEmail signUpWithEmail;
  late SignOut signOut;
  late GetCurrentUser getCurrentUser;
  late ForgotPassword forgotPassword;
  late UpdateUserProfile updateUser;

  late AuthBloc bloc;

  late SignInParams testSignInParams;
  late SignUpParams testSignUpParams;
  late UpdateUserProfileParams testUpdateUserParams;

  late SignInFailure testSignInFailure;
  late SignUpFailure testSignUpFailure;
  late SignOutFailure testSignOutFailure;
  late ForgotPasswordFailure testForgotPasswordFailure;
  late GetCurrentUserFailure testGetCurrentUserFailure;
  late UpdateUserFailure testUpdateUserFailure;

  setUp(() {
    signInWithEmail = MockSignInWithEmail();
    signInWithGoogle = MockSignInWithGoogle();
    signInAnonymously = MockSignInAnonymously();
    signUpWithEmail = MockSignUpWithEmail();
    signOut = MockSignOut();
    getCurrentUser = MockGetCurrentUser();
    forgotPassword = MockForgotPassword();
    updateUser = MockUpdateUserProfile();

    bloc = AuthBloc(
      signInWithEmail: signInWithEmail,
      signInWithGoogle: signInWithGoogle,
      signInAnonymously: signInAnonymously,
      signUpWithEmail: signUpWithEmail,
      signOut: signOut,
      forgotPassword: forgotPassword,
      getCurrentUser: getCurrentUser,
      updateUser: updateUser,
    );
    testSignInFailure = SignInFailure(
      message: 'message',
      statusCode: 500,
    );
    testSignUpFailure = SignUpFailure(
      message: 'message',
      statusCode: 500,
    );

    testGetCurrentUserFailure = GetCurrentUserFailure(
      message: 'message',
      statusCode: 500,
    );

    testSignOutFailure = SignOutFailure(
      message: 'message',
      statusCode: 500,
    );

    testForgotPasswordFailure = ForgotPasswordFailure(
      message: 'message',
      statusCode: 500,
    );

    testUpdateUserFailure = UpdateUserFailure(
      message: 'message',
      statusCode: 500,
    );
  });

  setUpAll(() {
    testSignInParams = const SignInParams.empty();
    testSignUpParams = const SignUpParams.empty();
    testUpdateUserParams = const UpdateUserProfileParams.empty();
    registerFallbackValue(testSignInParams);
    registerFallbackValue(testSignUpParams);
    registerFallbackValue(testUpdateUserParams);
  });

  tearDown(() => bloc.close());

  test(
      'given AuthBloc '
      'when bloc is instantiated '
      'then initial state should be [AuthInitial] ', () async {
    // Arrange
    // Act
    // Assert
    expect(bloc.state, const AuthInitial());
  });

  const testUser = UserEntity.empty();

  group('signInWithEmail - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signInWithEmail] is called '
      'and completed successfully '
      'then emit [AuthLoading, Authenticated]',
      build: () {
        when(
          () => signInWithEmail(any()),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SignInWithEmailEvent(
          email: testSignInParams.email,
          password: testSignInParams.password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (bloc) {
        verify(
          () => signInWithEmail(any()),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signInWithEmail] is called unsuccessful '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(
          () => signInWithEmail(any()),
        ).thenAnswer((_) async => Left(testSignInFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SignInWithEmailEvent(
          email: testSignInParams.email,
          password: testSignInParams.password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
      verify: (bloc) {
        verify(
          () => signInWithEmail(any()),
        ).called(1);
      },
    );
  });

  group('signInWithGoogle - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signUpWithEmail] is called '
      'and completed successfully '
      'then emit [AuthLoading, Authenticated]',
      build: () {
        when(() => signInWithGoogle()).thenAnswer(
          (_) async => const Right(testUser),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (_) {
        verify(() => signInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signInWithEmail] is called unsuccessful '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(() => signInWithGoogle()).thenAnswer(
          (_) async => Left(
            SignInFailure(
              message: 'Google sign-in failed',
              statusCode: 'GOOGLE_SIGN_IN_ERROR',
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
      verify: (_) {
        verify(() => signInWithGoogle()).called(1);
      },
    );
  });

  group('signInAnonymously - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signInAnonymously] is called '
      'and completed successfully '
      'then emit [AuthLoading, Authenticated]',
      build: () {
        when(
          () => signInAnonymously(),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInAnonymouslyEvent()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (bloc) {
        verify(
          () => signInAnonymously(),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signInAnonymously] is called unsuccessfully '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(
          () => signInAnonymously(),
        ).thenAnswer((_) async => Left(testSignInFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignInAnonymouslyEvent()),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
      verify: (bloc) {
        verify(
          () => signInAnonymously(),
        ).called(1);
      },
    );
  });

  group('updateUserProfile - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.updateUserProfile] is called '
      'and complete',
      build: () {
        when(
          () => updateUser(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateUserProfileEvent(
          action: testUpdateUserParams.action,
          userData: testUpdateUserParams.userData,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const UserProfileUpdated(),
      ],
      verify: (bloc) {
        verify(() => updateUser(testUpdateUserParams)).called(1);
        verifyNoMoreInteractions(updateUser);
      },
    );
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.updateUserProfile] is called '
      'then emit [AuthLoading, AuthError] ',
      build: () {
        when(
          () => updateUser(any()),
        ).thenAnswer((_) async => Left(testUpdateUserFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateUserProfileEvent(
          action: testUpdateUserParams.action,
          userData: testUpdateUserParams.userData,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        AuthError(message: testUpdateUserFailure.message),
      ],
      verify: (bloc) {
        verify(() => updateUser(testUpdateUserParams)).called(1);
        verifyNoMoreInteractions(updateUser);
      },
    );
  });

  group('signUpWithEmail - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signUpWithEmail] is called '
      'and completed successfully '
      'then emit [AuthLoading, Authenticated]',
      build: () {
        when(
          () => signUpWithEmail(any()),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SignUpWithEmailEvent(
          name: testSignUpParams.name,
          email: testSignUpParams.email,
          password: testSignUpParams.password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (bloc) {
        verify(() => signUpWithEmail(any())).called(1);
      },
    );
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signUpWithEmail] is called unsuccessful '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(
          () => signUpWithEmail(any()),
        ).thenAnswer((_) async => Left(testSignUpFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SignUpWithEmailEvent(
          name: testSignUpParams.name,
          email: testSignUpParams.email,
          password: testSignUpParams.password,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
      verify: (bloc) {
        verify(() => signUpWithEmail(any())).called(1);
      },
    );
  });

  group('signOut - ', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signOut] is called '
      'and completed successfully '
      'then emit [AuthLoading, SignedIn]',
      build: () {
        when(() => signOut()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => signOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.signOut] is called unsuccessful '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(() => signOut()).thenAnswer((_) async => Left(testSignOutFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthLoading(),
        AuthError(message: testSignOutFailure.message),
      ],
      verify: (_) {
        verify(() => signOut()).called(1);
      },
    );
  });

  group('ForgotPassword - ', () {
    const testEmail = 'test@mail.com';
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.forgotPassword] is called '
      'then emit [AuthLoading, ForgotPasswordSent]',
      build: () {
        when(
          () => forgotPassword(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ForgotPasswordEvent(
          email: testEmail,
        ),
      ),
      expect: () => [const AuthLoading(), const ForgotPasswordSent()],
      verify: (bloc) {
        verify(
          () => forgotPassword(testEmail),
        ).called(1);
        verifyNoMoreInteractions(forgotPassword);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [ForgotPassword] call is unsuccessful '
      'then emit [AuthLoading, AuthError] ',
      build: () {
        when(
          () => forgotPassword(any()),
        ).thenAnswer((_) async => Left(testForgotPasswordFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const ForgotPasswordEvent(
          email: testEmail,
        ),
      ),
      expect: () => [
        const AuthLoading(),
        AuthError(message: testForgotPasswordFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => forgotPassword(testEmail),
        ).called(1);
        verifyNoMoreInteractions(forgotPassword);
      },
    );
  });

  group('getCurrentUser -', () {
    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.getCurrentUser] is called '
      'and completed successfully '
      'then emit [AuthLoading, Authenticated]',
      build: () {
        when(
          () => getCurrentUser(),
        ).thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCurrentUserEvent()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (_) {
        verify(() => getCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.getCurrentUser] is called '
      'and no user found '
      'then emit [AuthLoading, Unauthenticated]',
      build: () {
        when(() => getCurrentUser()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCurrentUserEvent()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
      verify: (_) {
        verify(() => getCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given AuthBloc '
      'when [AuthBloc.getCurrentUser] is called unsuccessfully '
      'then emit [AuthLoading, AuthError]',
      build: () {
        when(
          () => getCurrentUser(),
        ).thenAnswer((_) async => Left(testGetCurrentUserFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCurrentUserEvent()),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
      ],
      verify: (_) {
        verify(() => getCurrentUser()).called(1);
      },
    );
  });
}
