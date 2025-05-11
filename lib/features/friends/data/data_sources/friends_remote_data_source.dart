import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/friends/data/models/friend_model.dart';
import 'package:sync_together/features/friends/data/models/friend_request_model.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';

/// **Remote Data Source for Friends & Friend Requests**
///
/// Handles all Firebase interactions related to friends and invitations.
abstract class FriendsRemoteDataSource {
  /// Sends a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> sendFriendRequest({required FriendRequest request});

  /// Accepts a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> acceptFriendRequest({required FriendRequest request});

  /// Rejects a friend request.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> rejectFriendRequest({required FriendRequest request});

  /// Removes a friend.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [FriendSystemException].
  Future<void> removeFriend({
    required String senderId,
    required String receiverId,
  });

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

  /// Searches for users by display name or email.
  ///
  /// - **Success:** Returns a list of [UserModel].
  /// - **Failure:** Throws an [FriendSystemException].
  Future<List<UserModel>> searchUsers(String query);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  FriendsRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<void> sendFriendRequest({required FriendRequest request}) async {
    try {
      final docRef = _friendRequests.doc();
      final friendRequest = (request as FriendRequestModel).copyWith(
        id: docRef.id,
        sentAt: DateTime.now(),
      );

      await docRef.set({
        'id': friendRequest.id,
        'senderId': friendRequest.senderId,
        'senderName': friendRequest.senderName,
        'receiverId': friendRequest.receiverId,
        'receiverName': friendRequest.receiverName,
        'sentAt': friendRequest.sentAt,
      });
    } on FirebaseAuthException catch (e) {
      throw SendRequestException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SendRequestException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> acceptFriendRequest({required FriendRequest request}) async {
    try {
      final friendRequestDocRef = _friendRequests.doc(request.id);
      final friendRequestDoc = await friendRequestDocRef.get();

      if (!friendRequestDoc.exists) throw Exception('Friend request not found');

      final friendDocRef = _friends.doc();
      await friendDocRef.set({
        'id': friendDocRef.id,
        'user1Id': request.senderId,
        'user1Name': request.senderName,
        'user2Id': request.receiverId,
        'user2Name': request.receiverName,
        'friendship': [
          request.senderId,
          request.senderName,
          request.receiverId,
          request.receiverName,
        ],
        'createdAt': Timestamp.now(),
      });

      await friendRequestDocRef.delete();
    } on FirebaseAuthException catch (e) {
      throw AcceptRequestException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw AcceptRequestException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> rejectFriendRequest({required FriendRequest request}) async {
    try {
      await _friendRequests.doc(request.id).delete();
    } on FirebaseAuthException catch (e) {
      throw RejectRequestException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw RejectRequestException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<List<FriendRequestModel>> getFriendRequests(String userId) async {
    try {
      final friendRequestsList = await _friendRequests
          .where(
            'receiverId',
            isEqualTo: userId,
          )
          .get()
          .then(
            (value) => value.docs
                .map(
                  (doc) => FriendRequestModel.fromMap(doc.data()),
                )
                .toList(),
          );

      return friendRequestsList;
    } on FirebaseAuthException catch (e) {
      throw GetFriendRequestsException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw GetFriendRequestsException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<List<FriendModel>> getFriends(String userId) async {
    try {
      final friendsList = await _friends.where('friendship', arrayContains: userId).get().then(
            (value) => value.docs
                .map(
                  (doc) => FriendModel.fromMap(doc.data()),
                )
                .toList(),
          );

      return friendsList;
    } on FirebaseAuthException catch (e) {
      throw GetFriendsException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw GetFriendsException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> removeFriend({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final querySnapshot = await _friends
          .where(
            'user1Id',
            isEqualTo: senderId,
          )
          .where(
            'user2Id',
            isEqualTo: receiverId,
          )
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw RemoveFriendException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw RemoveFriendException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) {
    try {
      return _users
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get()
          .then(
            (value) => value.docs
                .map(
                  (doc) => UserModel.fromMap(doc.data()),
                )
                .toList(),
          );
    } on FirebaseAuthException catch (e) {
      throw SearchUsersException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SearchUsersException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  CollectionReference<DataMap> get _friendRequests => firestore.collection(
        FirebaseConstants.friendRequestsCollection,
      );

  CollectionReference<DataMap> get _friends => firestore.collection(
        FirebaseConstants.friendsCollection,
      );

  CollectionReference<DataMap> get _users => firestore.collection(
        FirebaseConstants.usersCollection,
      );
}
