part of 'friend_bloc.dart';

/// Base state for Friend system.
sealed class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object> get props => [];
}

/// Initial state.
final class FriendInitial extends FriendState {
  const FriendInitial();
}

/// Loading state.
final class FriendLoading extends FriendState {
  const FriendLoading();
}

/// Success state for friend request actions.
final class FriendRequestSent extends FriendState {
  const FriendRequestSent();
}

/// Success state for accepting a request.
final class FriendRequestAccepted extends FriendState {
  const FriendRequestAccepted();
}

/// Success state for rejecting a request.
final class FriendRequestRejected extends FriendState {
  const FriendRequestRejected();
}

/// Success state for removing a friend.
final class FriendRemoved extends FriendState {
  const FriendRemoved();
}

/// State when friends are fetched.
final class FriendsLoaded extends FriendState {
  const FriendsLoaded(this.friends);

  final List<Friend> friends;

  @override
  List<Object> get props => [friends];
}

/// State when friend requests are fetched.
final class FriendRequestsLoaded extends FriendState {
  const FriendRequestsLoaded(this.requests);

  final List<FriendRequest> requests;

  @override
  List<Object> get props => [requests];
}

/// Error state.
final class FriendError extends FriendState {
  const FriendError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
