part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

final class SignInWithEmailEvent extends AuthEvent {
  const SignInWithEmailEvent({required this.email, required this.password});

  final String email;
  final String password;
  @override
  List<Object?> get props => [email, password];
}

final class GetCurrentUserEvent extends AuthEvent {
  const GetCurrentUserEvent();
}

final class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}

final class SignInAnonymouslyEvent extends AuthEvent {
  const SignInAnonymouslyEvent();
}

final class SignUpWithEmailEvent extends AuthEvent {
  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}
