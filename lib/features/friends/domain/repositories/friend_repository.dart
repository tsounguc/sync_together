import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';

/// **Repository contract for handling friends and invitations**.
///
/// Defines the contract for Friend System & Invitations operations.
/// This allows the app to remain **independent of Firebase** or any other backend.
///
/// Each method **returns an Either type** (`ResultFuture<T>`),
/// ensuring that failures are handled explicitly instead of using exceptions.
abstract class FriendRepository {
  /// Sends a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid sentFriendRequest({
    required String senderId,
    required String receivedId,
  });

  /// Accepts a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid acceptFriendRequest({
    required String senderId,
    required String receivedId,
  });

  /// Rejects a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid rejectFriendRequest({
    required String senderId,
    required String receivedId,
  });

  /// Removes a friend.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid removeFriend({
    required String senderId,
    required String receivedId,
  });

  /// Retrieves the list of friends.
  ///
  /// - **Success:** Returns a list of [Friend].
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultFuture<List<Friend>> getFriends(String userId);

  /// Retrieves incoming friend requests.
  ///
  /// - **Success:** Returns a list of [FriendRequest].
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultFuture<List<FriendRequest>> getFriendsRequests(String userId);
}
