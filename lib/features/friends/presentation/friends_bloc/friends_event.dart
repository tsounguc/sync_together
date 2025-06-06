part of 'friends_bloc.dart';

/// Base event for the Friend system.
sealed class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object> get props => [];
}

/// Event to send a friend request.
final class SendFriendRequestEvent extends FriendEvent {
  const SendFriendRequestEvent(this.request);

  final FriendRequest request;

  @override
  List<Object> get props => [request];
}

/// Event to accept a friend request.
final class AcceptFriendRequestEvent extends FriendEvent {
  const AcceptFriendRequestEvent(this.request);

  final FriendRequest request;

  @override
  List<Object> get props => [request];
}

/// Event to reject a friend request.
final class RejectFriendRequestEvent extends FriendEvent {
  const RejectFriendRequestEvent(this.request);

  final FriendRequest request;

  @override
  List<Object> get props => [request];
}

/// Event to remove a friend.
final class RemoveFriendEvent extends FriendEvent {
  const RemoveFriendEvent({
    required this.senderId,
    required this.receiverId,
  });

  final String senderId;
  final String receiverId;

  @override
  List<Object> get props => [senderId, receiverId];
}

/// Event to fetch all friends for a user.
final class GetFriendsEvent extends FriendEvent {
  const GetFriendsEvent({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to fetch all incoming friend requests.
final class GetFriendRequestsEvent extends FriendEvent {
  const GetFriendRequestsEvent({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to fetch users
class SearchUsersEvent extends FriendEvent {
  const SearchUsersEvent({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}
