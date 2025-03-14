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
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

final class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

final class ForgotPasswordEvent extends AuthEvent {
  const ForgotPasswordEvent({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [email];
}

class UpdateUserProfileEvent extends AuthEvent {
  UpdateUserProfileEvent({
    required this.action,
    required this.userData,
  }) : assert(
          userData is String || userData is File || userData is Map,
          '[userData] must be either a String, File, or Map '
          'but was ${userData.runtimeType}',
        );

  final UpdateUserAction action;
  final dynamic userData;

  @override
  List<Object?> get props => [action, userData];
}
