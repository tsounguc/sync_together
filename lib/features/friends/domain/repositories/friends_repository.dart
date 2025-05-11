import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';

/// **Repository contract for handling friends and invitations**.
///
/// Defines the contract for Friend System & Invitations operations.
/// This allows the app to remain **independent of Firebase**
/// or any other backend.
///
/// Each method **returns an Either type** (`ResultFuture<T>`),
/// ensuring that failures are handled explicitly instead of using exceptions.
abstract class FriendsRepository {
  /// Sends a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid sendFriendRequest({required FriendRequest request});

  /// Accepts a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid acceptFriendRequest({
    required FriendRequest request,
  });

  /// Rejects a friend request.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid rejectFriendRequest({
    required FriendRequest request,
  });

  /// Removes a friend.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `FriendsFailure`.
  ResultVoid removeFriend({
    required String senderId,
    required String receiverId,
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
  ResultFuture<List<FriendRequest>> getFriendRequests(String userId);

  /// Searches for users by display name or email.
  ///
  /// - **Success:** Returns a list of [UserEntity].
  /// - **Failure:** Returns a 'SearchUsersFailure'.
  ResultFuture<List<UserEntity>> searchUsers(String query);
}
