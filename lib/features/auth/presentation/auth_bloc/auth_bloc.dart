import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/use_cases/get_current_user.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_out.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_up_with_email.dart';

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
  })  : _signInWithEmail = signInWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _signInAnonymously = signInAnonymously,
        _signUpWithEmail = signUpWithEmail,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(AuthInitial()) {
    on<SignInWithEmailEvent>(_signInWithEmailHandler);
    on<SignInWithGoogleEvent>(_signInWithGoogleHandler);
    on<SignInAnonymouslyEvent>(_signInAnonymouslyHandler);
    on<SignUpWithEmailEvent>(_signUpWithEmailHandler);
    on<SignOutEvent>(_signOutHandler);
    on<GetCurrentUserEvent>(_getCurrentUserHandler);
  }

  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAnonymously _signInAnonymously;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

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
      SignUpParams(email: event.email, password: event.password),
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
      (user) => user != null ? emit(Authenticated(user: user)) : emit(const Unauthenticated()),
    );
  }
}
