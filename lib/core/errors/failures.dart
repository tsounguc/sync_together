import 'package:equatable/equatable.dart';
import 'package:sync_together/core/errors/exceptions.dart';

/// Base class for handling failures across the app.
///
/// [Failure] ensures all errors are **typed**,
/// rather than using raw exceptions.
/// This helps with **better error handling** and **functional programming**.
///
/// - `message`: Human-readable error description.
/// - `statusCode`: Can be an `int` (e.g., HTTP 404) or
/// `String` (e.g., Firebase error codes).
abstract class Failure extends Equatable {
  /// Creates a [Failure] instance.
  ///
  /// - **message**: Describes the error.
  /// - **statusCode**: Can be an integer (e.g., HTTP error codes) or
  /// a string (e.g., Firebase error codes).
  Failure({required this.message, required this.statusCode})
      : assert(
          statusCode is String || statusCode is int,
          'StatusCode cannot be a ${statusCode.runtimeType}',
        );

  /// The error message (human-readable).
  final String message;

  /// Error code, which may be an `int` (for HTTP errors)
  /// or `String` (Firebase errors).
  final dynamic statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// **Base class for all authentication failures.**
///
/// This allows us to have specific failure types (e.g., `SignUpFailure`).
abstract class AuthFailure extends Failure {
  AuthFailure({
    required super.message,
    required super.statusCode,
  });
}

/// **Failure that occurs during sign-up.**
class SignUpFailure extends AuthFailure {
  SignUpFailure({required super.message, required super.statusCode});

  /// Converts a [SignUpException] into a [SignUpFailure].
  SignUpFailure.fromException(
    SignUpException exception,
  ) : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs during sign-in.**
class SignInFailure extends AuthFailure {
  SignInFailure({
    required super.message,
    required super.statusCode,
  });

  /// Converts a [SignInException] into a [SignInFailure].
  SignInFailure.fromException(SignInException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs during sign-out.**
class SignOutFailure extends AuthFailure {
  SignOutFailure({required super.message, required super.statusCode});

  /// Converts a [SignOutException] into a [SignOutFailure].
  SignOutFailure.fromException(SignOutException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs during password reset.**
class ForgotPasswordFailure extends AuthFailure {
  ForgotPasswordFailure({required super.message, required super.statusCode});

  /// Converts a [ForgotPasswordException] into a [ForgotPasswordFailure].
  ForgotPasswordFailure.fromException(ForgotPasswordException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when get-current-user.**
class GetCurrentUserFailure extends AuthFailure {
  GetCurrentUserFailure({required super.message, required super.statusCode});

  /// Converts a [GetCurrentUserException] into a [GetCurrentUserFailure].
  GetCurrentUserFailure.fromException(GetCurrentUserException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when user update profile.**
class UpdateUserFailure extends AuthFailure {
  UpdateUserFailure({required super.message, required super.statusCode});

  /// Converts a [UpdateUserException] into a [UpdateUserFailure].
  UpdateUserFailure.fromException(UpdateUserException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Base class for all Friends system failures.**
///
/// This allows us to have specific failure types.
abstract class FriendFailure extends Failure {
  FriendFailure({
    required super.message,
    required super.statusCode,
  });
}

/// **Failure that occurs when user sends a friend request.**
class SendRequestFailure extends FriendFailure {
  SendRequestFailure({required super.message, required super.statusCode});

  /// Converts a [SendRequestException] into a [SendRequestFailure].
  SendRequestFailure.fromException(SendRequestException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when user accepts a friend request.**
class AcceptRequestFailure extends FriendFailure {
  AcceptRequestFailure({required super.message, required super.statusCode});

  /// Converts a [AcceptRequestException] into a [AcceptRequestFailure].
  AcceptRequestFailure.fromException(AcceptRequestException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when user rejects a friend request.**
class RejectRequestFailure extends FriendFailure {
  RejectRequestFailure({required super.message, required super.statusCode});

  /// Converts a [RejectRequestException] into a [RejectRequestFailure].
  RejectRequestFailure.fromException(RejectRequestException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when user removes a friend.**
class RemoveFriendFailure extends FriendFailure {
  RemoveFriendFailure({required super.message, required super.statusCode});

  /// Converts a [RemoveFriendException] into a [RemoveFriendFailure].
  RemoveFriendFailure.fromException(RemoveFriendException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when getting list of friends.**
class GetFriendsFailure extends FriendFailure {
  GetFriendsFailure({required super.message, required super.statusCode});

  /// Converts a [GetFriendsException] into a [GetFriendsFailure].
  GetFriendsFailure.fromException(GetFriendsException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when getting list of friend requests.**
class GetFriendRequestsFailure extends FriendFailure {
  GetFriendRequestsFailure({required super.message, required super.statusCode});

  /// Converts a [GetFriendRequestsException] into a [GetFriendRequestsFailure].
  GetFriendRequestsFailure.fromException(GetFriendRequestsException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when getting list of friend requests.**
class SearchUsersFailure extends FriendFailure {
  SearchUsersFailure({required super.message, required super.statusCode});

  /// Converts a [SearchUsersException] into a [SearchUsersFailure].
  SearchUsersFailure.fromException(SearchUsersException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Base class for all watch party failures.**
///
/// This allows us to have specific failure types.
abstract class WatchPartyFailure extends Failure {
  WatchPartyFailure({
    required super.message,
    required super.statusCode,
  });
}

/// **Failure that occurs when creating a watch party.**
class CreateWatchPartyFailure extends WatchPartyFailure {
  CreateWatchPartyFailure({required super.message, required super.statusCode});

  /// Converts a [CreateWatchPartyException] into a [CreateWatchPartyFailure].
  CreateWatchPartyFailure.fromException(CreateWatchPartyException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when joining a watch party.**
class JoinWatchPartyFailure extends WatchPartyFailure {
  JoinWatchPartyFailure({required super.message, required super.statusCode});

  /// Converts a [JoinWatchPartyException] into a [JoinWatchPartyFailure].
  JoinWatchPartyFailure.fromException(JoinWatchPartyException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when getting list of public watch parties.**
class GetPublicWatchPartiesFailure extends WatchPartyFailure {
  GetPublicWatchPartiesFailure({
    required super.message,
    required super.statusCode,
  });

  /// Converts a [GetPublicWatchPartiesException] into a [GetPublicWatchPartiesFailure].
  GetPublicWatchPartiesFailure.fromException(GetPublicWatchPartiesException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when getting a watch party.**
class GetWatchPartyFailure extends WatchPartyFailure {
  GetWatchPartyFailure({required super.message, required super.statusCode});

  /// Converts a [GetWatchPartyException] into a [GetWatchPartyFailure].
  GetWatchPartyFailure.fromException(GetWatchPartyException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when starting a watch party.**
class StartWatchPartyFailure extends WatchPartyFailure {
  StartWatchPartyFailure({required super.message, required super.statusCode});

  /// Converts a [StartWatchPartyException] into a [StartWatchPartyFailure].
  StartWatchPartyFailure.fromException(StartWatchPartyException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when syncing a watch party.**
class SyncWatchPartyFailure extends WatchPartyFailure {
  SyncWatchPartyFailure({required super.message, required super.statusCode});

  /// Converts a [SyncWatchPartyException] into a [SyncWatchPartyFailure].
  SyncWatchPartyFailure.fromException(SyncWatchPartyException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Base class for all streaming platforms failures.**
///
/// This allows us to have specific failure types.
abstract class StreamingPlatformsFailure extends Failure {
  StreamingPlatformsFailure({
    required super.message,
    required super.statusCode,
  });
}

/// **Failure that occurs when loading streaming platforms.**
class LoadPlatformsFailure extends StreamingPlatformsFailure {
  LoadPlatformsFailure({
    required super.message,
    required super.statusCode,
  });

  /// Converts a [LoadPlatformsException] into a [LoadPlatformsFailure].
  LoadPlatformsFailure.fromException(LoadPlatformsException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Base class for all message failures.**
///
/// This allows us to have specific failure types.
abstract class MessageFailure extends Failure {
  MessageFailure({
    required super.message,
    required super.statusCode,
  });
}

/// **Failure that occurs when sending a message.**
class SendMessageFailure extends MessageFailure {
  SendMessageFailure({
    required super.message,
    required super.statusCode,
  });

  /// Converts a [SendMessageException] into a [SendMessageFailure].
  SendMessageFailure.fromException(SendMessageException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}

/// **Failure that occurs when listening to messages.**
class ListenToMessagesFailure extends MessageFailure {
  ListenToMessagesFailure({
    required super.message,
    required super.statusCode,
  });

  /// Converts a [ListenToMessagesException] into a [ListenToMessagesFailure].
  ListenToMessagesFailure.fromException(ListenToMessagesException exception)
      : this(
          message: exception.message,
          statusCode: exception.statusCode,
        );
}
