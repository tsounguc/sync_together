import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/use_cases/forgot_password.dart';
import 'package:sync_together/features/auth/domain/use_cases/get_current_user.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_out.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/update_user_profile.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInAnonymously signInAnonymously,
    required SignUpWithEmail signUpWithEmail,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required ForgotPassword forgotPassword,
    required UpdateUserProfile updateUser,
  })  : _signInWithEmail = signInWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signInAnonymously = signInAnonymously,
        _signUpWithEmail = signUpWithEmail,
        _forgotPassword = forgotPassword,
        _updateUser = updateUser,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AuthInitial()) {
    on<SignInWithEmailEvent>(_signInWithEmailHandler);
    on<SignInWithGoogleEvent>(_signInWithGoogleHandler);
    on<SignInAnonymouslyEvent>(_signInAnonymouslyHandler);
    on<SignUpWithEmailEvent>(_signUpWithEmailHandler);
    on<SignOutEvent>(_signOutHandler);
    on<GetCurrentUserEvent>(_getCurrentUserHandler);
    on<ForgotPasswordEvent>(_forgotPasswordHandler);
    on<UpdateUserProfileEvent>(_updateUserHandler);
  }

  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAnonymously _signInAnonymously;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final ForgotPassword _forgotPassword;
  final UpdateUserProfile _updateUser;

  Future<void> _signInWithEmailHandler(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithEmail(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _signInWithGoogleHandler(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _signInAnonymouslyHandler(
    SignInAnonymouslyEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInAnonymously();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _signUpWithEmailHandler(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUpWithEmail(
      SignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _signOutHandler(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signOut();

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (success) => emit(const Unauthenticated()),
    );
  }

  Future<void> _getCurrentUserHandler(
    GetCurrentUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => user != null
          ? emit(
              Authenticated(user: user),
            )
          : emit(
              const Unauthenticated(),
            ),
    );
  }

  Future<void> _forgotPasswordHandler(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _forgotPassword(event.email);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (success) => emit(const ForgotPasswordSent()),
    );
  }

  Future<void> _updateUserHandler(
    UpdateUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _updateUser(
      UpdateUserProfileParams(
        action: event.action,
        userData: event.userData,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (success) => emit(const UserProfileUpdated()),
    );
  }
}
