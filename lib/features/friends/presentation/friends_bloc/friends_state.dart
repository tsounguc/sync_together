part of 'friends_bloc.dart';

/// Base state for Friend system.
sealed class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object> get props => [];
}

/// Initial state.
final class FriendsInitial extends FriendsState {
  const FriendsInitial();
}

/// Loading state.
final class FriendsLoadingState extends FriendsState {
  const FriendsLoadingState();
}

/// Success state for friend request actions.
final class FriendRequestSent extends FriendsState {
  const FriendRequestSent();
}

/// Success state for accepting a request.
final class FriendRequestAccepted extends FriendsState {
  const FriendRequestAccepted();
}

/// Success state for rejecting a request.
final class FriendRequestRejected extends FriendsState {
  const FriendRequestRejected();
}

/// Success state for removing a friend.
final class FriendRemoved extends FriendsState {
  const FriendRemoved();
}

/// State when friends are fetched.
final class FriendsLoaded extends FriendsState {
  const FriendsLoaded(this.friends);

  final List<Friend> friends;

  @override
  List<Object> get props => [friends];
}

/// State when friend requests are fetched.
final class FriendRequestsLoaded extends FriendsState {
  const FriendRequestsLoaded(this.requests);

  final List<FriendRequest> requests;

  @override
  List<Object> get props => [requests];
}

/// State when users are fetched
final class UsersLoaded extends FriendsState {
  const UsersLoaded(this.users);

  final List<UserEntity> users;
}

/// Error state.
final class FriendsError extends FriendsState {
  const FriendsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
