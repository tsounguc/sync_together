import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/friends/data/data_sources/friends_remote_data_source.dart';
import 'package:sync_together/features/friends/data/models/friend_model.dart';
import 'package:sync_together/features/friends/data/models/friend_request_model.dart';

void main() {
  late FirebaseFirestore firestore;
  late FriendsRemoteDataSourceImpl remoteDataSourceImpl;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remoteDataSourceImpl = FriendsRemoteDataSourceImpl(firestore);
  });

  const testSenderId = '123';
  const testReceiverId = '456';
  final testRequest = FriendRequestModel.empty().copyWith(
    id: '1',
    senderId: testSenderId,
    receiverId: testReceiverId,
  );

  final testFriend = FriendModel.empty().copyWith(
    id: '1',
    user1Id: testSenderId,
    user2Id: testReceiverId,
  );

  Future<void> sendRequest(FriendRequestModel request) async {
    return firestore
        .collection(FirebaseConstants.friendRequestsCollection)
        .doc(
          request.id,
        )
        .set(request.toMap());
  }

  Future<DocumentReference> addFriend(FriendModel friendship) async {
    final data = friendship.toMap();

    data['friendship'] = [
      friendship.user1Id,
      friendship.user1Name,
      friendship.user2Id,
      friendship.user2Name,
    ];

    return firestore
        .collection(
          FirebaseConstants.friendsCollection,
        )
        .add(data);
  }

  Future<QuerySnapshot<DataMap>> getRequests(String receiverId) async => firestore
      .collection(
        FirebaseConstants.friendRequestsCollection,
      )
      .where('receiverId', isEqualTo: receiverId)
      .get();

  Future<QuerySnapshot<DataMap>> getFriends(String userId) async => firestore
      .collection(
        FirebaseConstants.friendsCollection,
      )
      .where('friendship', arrayContains: userId)
      .get();

  group('sendFriendRequest - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.sendFriendRequest] is called '
      'then complete successfully ',
      () async {
        // Arrange

        // Act
        await remoteDataSourceImpl.sendFriendRequest(
          request: testRequest,
        );

        //   Assert
        final requestsDocs = await getRequests(testReceiverId);
        expect(
          requestsDocs.docs,
          hasLength(1),
        );
        expect(
          requestsDocs.docs[0]['senderId'],
          equals(testRequest.senderId),
        );
      },
    );
  });

  group('acceptFriendRequest - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.acceptFriendRequest] is called '
      'then remove from list of friend requests list '
      'and complete successfully ',
      () async {
        // Arrange
        await sendRequest(testRequest);

        // Act
        await remoteDataSourceImpl.acceptFriendRequest(
          request: testRequest,
        );

        //   Assert
        final friendsDocs = await getFriends(testSenderId);
        final requestsDocs = await getRequests(testReceiverId);
        expect(
          requestsDocs.docs,
          hasLength(0),
        );
        expect(
          friendsDocs.docs[0]['user1Id'],
          equals(testRequest.senderId),
        );
      },
    );
  });

  group('rejectFriendRequest - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.rejectFriendRequest] is called '
      'then remove from list of friend requests list '
      'and complete successfully ',
      () async {
        // Arrange
        await sendRequest(testRequest);
        // Act
        await remoteDataSourceImpl.rejectFriendRequest(
          request: testRequest,
        );

        //   Assert
        final requestsDocs = await getRequests(testReceiverId);
        expect(
          requestsDocs.docs,
          hasLength(0),
        );
      },
    );
  });

  group('removeFriend - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.removeFriend] is called '
      'then remove friendship from the friends list '
      'and complete successfully ',
      () async {
        // Arrange
        await addFriend(testFriend);

        // Act
        await remoteDataSourceImpl.removeFriend(
          senderId: testFriend.user1Id,
          receiverId: testFriend.user2Id,
        );

        //   Assert
        final friendsDocs = await getFriends(testSenderId);
        expect(
          friendsDocs.docs,
          hasLength(0),
        );
      },
    );
  });

  group('getFriends - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.getFriends] is called '
      'then return a [List<Friend>] ',
      () async {
        // Arrange
        await addFriend(testFriend);
        final testFriend2 = testFriend.copyWith(
          id: '2',
          user1Id: testSenderId,
          user2Id: 'Jake',
        );
        await addFriend(testFriend2);

        // Act
        final result = await remoteDataSourceImpl.getFriends(
          testFriend.user1Id,
        );

        //   Assert
        expect(
          result,
          hasLength(2),
        );
      },
    );
  });

  group('getFriendRequests - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.sendFriendRequest] is called '
      'then complete successfully ',
      () async {
        // Arrange

        // Act
        await remoteDataSourceImpl.sendFriendRequest(
          request: testRequest,
        );

        //   Assert
        final requestsDocs = await getRequests(testReceiverId);
        expect(
          requestsDocs.docs,
          hasLength(1),
        );
        expect(
          requestsDocs.docs[0]['senderId'],
          equals(testRequest.senderId),
        );
      },
    );
  });

  group('searchUsers - ', () {
    test(
      'given FriendsRemoteDataSourceImpl '
      'when [FriendsRemoteDataSourceImpl.searchUsers] is called '
      'then complete successfully ',
      () async {
        // Arrange
        await firestore.collection(FirebaseConstants.usersCollection).add(
              const UserModel(
                uid: '1',
                displayName: 'John Doe',
                email: 'john@example.com',
              ).toMap(),
            );
        const testQuery = 'John Doe';

        // Act
        final result = await remoteDataSourceImpl.searchUsers(testQuery);

        // Assert
        expect(
          result,
          isA<List<UserModel>>(),
        );
        expect(
          result[0].displayName,
          testQuery,
        );
      },
    );
  });
}
