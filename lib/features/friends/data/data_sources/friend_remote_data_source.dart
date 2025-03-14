import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/data/models/friend_model.dart';
import 'package:sync_together/features/friends/data/models/friend_request_model.dart';

/// **Remote Data Source for Friends & Friend Requests**
///
/// Handles all Firebase interactions related to friends and invitations.
abstract class FriendRemoteDataSource {
  /// Sends a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> sendFriendRequest({required String senderId, required String receiverId});

  /// Accepts a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> acceptFriendRequest({required String requestId});

  /// Rejects a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> rejectFriendRequest({required String requestId});

  /// Removes a friend.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> removeFriend({required String senderId, required String receiverId});

  /// Retrieves a list of friends for a given user.
  ///
  /// - **Success:** Returns a list of [FriendModel].
  /// - **Failure:** Throws an [FriendSystemException].
  Future<List<FriendModel>> getFriends(String userId);

  /// Retrieves incoming friend requests for a user.
  ///
  /// - **Success:** Returns a list of [FriendRequestModel].
  /// - **Failure:** Throws an [FriendSystemException].
  Future<List<FriendRequestModel>> getFriendRequests(String userId);
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  FriendRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;
  @override
  Future<void> acceptFriendRequest({required String requestId}) async {
    final docRef = _friendRequests.doc(requestId);
    final doc = await docRef.get();

    if (!doc.exists) throw Exception('Friend request not found');

    final data = doc.data()!;
    await _friends.add({
      'user1Id': data['senderId'],
      'user2Id': data['receiverId'],
      'createdAt': Timestamp.now(),
    });

    await docRef.delete();
  }

  @override
  Future<List<FriendRequestModel>> getFriendRequests(String userId) async {
    final friendRequestsList = await _friendRequests.where('receiverId', isEqualTo: userId).get().then(
          (value) => value.docs
              .map(
                (doc) => FriendRequestModel.fromMap(doc.data()),
              )
              .toList(),
        );

    return friendRequestsList;
  }

  @override
  Future<List<FriendModel>> getFriends(String userId) async {
    final friendsList = await _friends.where('user1Id', isEqualTo: userId).get().then(
          (value) => value.docs
              .map(
                (doc) => FriendModel.fromMap(doc.data()),
              )
              .toList(),
        );

    return friendsList;
  }

  @override
  Future<void> rejectFriendRequest({required String requestId}) async {
    await _friendRequests.doc(requestId).delete();
  }

  @override
  Future<void> removeFriend({
    required String senderId,
    required String receiverId,
  }) async {
    final querySnapshot =
        await _friends.where('user1Id', isEqualTo: senderId).where('user2Id', isEqualTo: receiverId).get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    await _friendRequests.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'sentAt': Timestamp.now(),
    });
  }

  CollectionReference<DataMap> get _friendRequests => firestore.collection(
        FirebaseConstants.friendRequestsCollection,
      );

  CollectionReference<DataMap> get _friends => firestore.collection(
        FirebaseConstants.friendsCollection,
      );
}
