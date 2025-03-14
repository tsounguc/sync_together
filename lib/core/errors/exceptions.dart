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

/// **Exception thrown during user profile update errors.**
class UpdateUserException extends AuthException {
  const UpdateUserException({
    required super.message,
    required super.statusCode,
  });
}

/// **Base class for all friend system exceptions.**
abstract class FriendSystemException extends Equatable implements Exception {
  const FriendSystemException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}
/// **Exception thrown during send friend request errors.**
class SendRequestException extends FriendSystemException {
  const SendRequestException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during accept friend request errors.**
class AcceptRequestException extends FriendSystemException {
  const AcceptRequestException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during reject friend request errors.**
class RejectRequestException extends FriendSystemException {
  const RejectRequestException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during remove friend request errors.**
class RemoveFriendException extends FriendSystemException {
  const RemoveFriendException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during remove friend request errors.**
class GetFriendsException extends FriendSystemException {
  const GetFriendsException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown during remove friend request errors.**
class GetFriendRequestsException extends FriendSystemException {
  const GetFriendRequestsException({
    required super.message,
    required super.statusCode,
  });
}
