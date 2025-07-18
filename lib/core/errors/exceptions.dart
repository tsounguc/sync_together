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

/// **Exception thrown during remove a friend errors.**
class RemoveFriendException extends FriendSystemException {
  const RemoveFriendException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when getting list of friends.**
class GetFriendsException extends FriendSystemException {
  const GetFriendsException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when getting list of friend request.**
class GetFriendRequestsException extends FriendSystemException {
  const GetFriendRequestsException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when searching users.**
class SearchUsersException extends FriendSystemException {
  const SearchUsersException({
    required super.message,
    required super.statusCode,
  });
}

/// **Base class for all watch party exceptions.**
abstract class WatchPartyException extends Equatable implements Exception {
  const WatchPartyException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// **Exception thrown when creating a watch party.**
class CreateWatchPartyException extends WatchPartyException {
  const CreateWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when getting a watch party.**
class GetWatchPartyException extends WatchPartyException {
  const GetWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when joining a watch party.**
class JoinWatchPartyException extends WatchPartyException {
  const JoinWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when syncing a watch party.**
class SyncWatchPartyException extends WatchPartyException {
  const SyncWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when leaving a watch party.**
class LeaveWatchPartyException extends WatchPartyException {
  const LeaveWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when ending a watch party.**
class EndWatchPartyException extends WatchPartyException {
  const EndWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when listen to participants in a watch party.**
class ListenToParticipantsException extends WatchPartyException {
  const ListenToParticipantsException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when listening to if watch party has started.**
class ListenToPartyStartException extends WatchPartyException {
  const ListenToPartyStartException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when listening to if watch party exists.**
class ListenToPartyExistenceException extends WatchPartyException {
  const ListenToPartyExistenceException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when starting a watch party.**
class StartWatchPartyException extends WatchPartyException {
  const StartWatchPartyException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when getting list of public watch parties.**
class GetPublicWatchPartiesException extends WatchPartyException {
  const GetPublicWatchPartiesException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when sending real-time playback sync data.**
class SendSyncDataException extends WatchPartyException {
  const SendSyncDataException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when getting a user by id.**
class GetUserByIdException extends WatchPartyException {
  const GetUserByIdException({
    required super.message,
    required super.statusCode,
  });
}

class GetSyncedDataException extends WatchPartyException {
  const GetSyncedDataException({
    required super.message,
    required super.statusCode,
  });
}

class UpdateVideoUrlException extends WatchPartyException {
  const UpdateVideoUrlException({
    required super.message,
    required super.statusCode,
  });
}

/// **Base class for all streaming platforms exceptions.**
abstract class StreamingPlatformsException extends Equatable
    implements Exception {
  const StreamingPlatformsException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// **Exception thrown when loading platforms.**
class LoadPlatformsException extends StreamingPlatformsException {
  const LoadPlatformsException({
    required super.message,
    required super.statusCode,
  });
}

/// **Base class for all message exceptions.**
abstract class MessageException extends Equatable implements Exception {
  const MessageException({
    required this.message,
    required this.statusCode,
  });

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// **Exception thrown when sending a message.**
class SendMessageException extends MessageException {
  const SendMessageException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when listening a message.**
class ListenToMessagesException extends MessageException {
  const ListenToMessagesException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when deleting a message.**
class DeleteMessageException extends MessageException {
  const DeleteMessageException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when clearing messages in a room**
class ClearRoomMessagesException extends MessageException {
  const ClearRoomMessagesException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when editing a message**
class EditMessageException extends MessageException {
  const EditMessageException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when fetching messages**
class FetchMessagesException extends MessageException {
  const FetchMessagesException({
    required super.message,
    required super.statusCode,
  });
}

/// **Exception thrown when setting typing status
class SetTypingStatusException extends MessageException {
  const SetTypingStatusException({
    required super.message,
    required super.statusCode,
  });
}

class ListenToTypingUsersException extends MessageException {
  const ListenToTypingUsersException({
    required super.message,
    required super.statusCode,
  });
}
