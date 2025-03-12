import 'package:equatable/equatable.dart';

/// **Base class for all authentication-related exceptions.**
abstract class AuthException extends Equatable implements Exception {
  const AuthException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// **Exception thrown during sign-up errors.**
class SignUpException extends AuthException {
  const SignUpException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during sign-in errors.**
class SignInException extends AuthException {
  const SignInException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during sign-out errors.**
class SignOutException extends AuthException {
  const SignOutException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during get-current-user errors.**
class GetCurrentUserException extends AuthException {
  const GetCurrentUserException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during password reset errors.**
class ForgotPasswordException extends AuthException {
  const ForgotPasswordException({
    required super.message,
    required super.statusCode,
  });
}
