import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';

void main() {
  late FirebaseFirestore firestore;
  late WatchPartyRemoteDataSourceImpl remoteDataSourceImpl;
  final testParty = WatchPartyModel.empty();

  setUp(() {
    firestore = FakeFirebaseFirestore();
    remoteDataSourceImpl = WatchPartyRemoteDataSourceImpl(firestore);
    registerFallbackValue(testParty);
  });

  Future<void> createParty(WatchPartyModel watchParty) async {
    return firestore
        .collection(
          FirebaseConstants.watchPartiesCollection,
        )
        .doc(watchParty.id)
        .set(
          watchParty.toMap(),
        );
  }

  Future<QuerySnapshot<DataMap>> getParties() async =>
      firestore.collection(FirebaseConstants.watchPartiesCollection).get();

  Future<DocumentSnapshot<DataMap>> getParty(
    WatchPartyModel watchParty,
  ) async =>
      firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(
            watchParty.id,
          )
          .get();

  group('createWatchParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when [WatchPartyRemoteDataSourceImpl.createWatchParty] is called '
      'then upload [WatchPartyModel] to  watch_parties collection',
      () async {
        // Arrange

        // Act
        final result = await remoteDataSourceImpl.createWatchParty(
          party: testParty,
        );

        // Assert
        final partiesDoc = await getParties();

        expect(
          partiesDoc.docs,
          hasLength(1),
        );
        expect(partiesDoc.docs[0]['id'], result.id);
        expect(partiesDoc.docs[0]['title'], result.title);
        expect(partiesDoc.docs[0]['hostId'], result.hostId);
        expect(partiesDoc.docs[0]['videoUrl'], result.videoUrl);
      },
    );
  });

  group('joinWatchParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when joinWatchParty is called '
      'then add userId to participantIds in Firestore',
      () async {
        // Arrange
        await createParty(testParty);

        // Act
        final result = await remoteDataSourceImpl.joinWatchParty(
          partyId: testParty.id,
          userId: 'user_123',
        );
        final partyDocRef = await getParty(testParty);

        // Assert
        expect(partyDocRef, isNotNull);
        expect(partyDocRef['participantIds'], contains('user_123'));
        expect(result.id, equals(testParty.id));
      },
    );
  });

  group('getPublicWatchParties - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when getPublicWatchParties is called '
      'then return only public WatchPartyModel sorted by createdAt descending',
      () async {
        final publicParty1 = testParty.copyWith(
          id: 'public_1',
          isPrivate: false,
          createdAt: DateTime.utc(2025),
        );

        final publicParty2 = testParty.copyWith(
          id: 'public_2',
          isPrivate: false,
          createdAt: DateTime.utc(2025, 3),
        );

        final privateParty = testParty.copyWith(
          id: 'private_1',
          isPrivate: true,
          createdAt: DateTime.utc(2025, 2),
        );

        await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(publicParty1.id)
            .set(publicParty1.toMap());

        await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(publicParty2.id)
            .set(publicParty2.toMap());

        await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(privateParty.id)
            .set(privateParty.toMap());

        // Act
        final result = await remoteDataSourceImpl.getPublicWatchParties();

        // Assert
        expect(result, hasLength(2));
        expect(result.every((party) => party.isPrivate == false), isTrue);

        // Ensure they are sorted by createdAt DESCENDING
        expect(result.first.id, equals(publicParty2.id));
        expect(result.last.id, equals(publicParty1.id));
      },
    );
  });

  group('getWatchParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl, '
      'when getWatchParty is called with valid ID '
      'then return the correct Watch party',
      () async {
        // Arrange
        await createParty(testParty);

        // Act
        final result = await remoteDataSourceImpl.getWatchParty(testParty.id);

        // Assert
        expect(result, isA<WatchPartyModel>());
        expect(result.id, equals(testParty.id));
      },
    );
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when getWatchParty is called with non-existing ID '
      'then throw GetWatchPartyException',
      () async {
        // Arrange
        const nonExistentId = 'non_existent_party';

        // Act
        final call = remoteDataSourceImpl.getWatchParty;

        // Assert
        expect(
          () => call(nonExistentId),
          throwsA(isA<GetWatchPartyException>()),
        );
      },
    );
  });

  group('leaveWatchParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when leaveWatchParty is called '
      'then userId is removed from participantIds in Firestore',
      () async {
        // Arrange
        const userId = 'user_123';
        await createParty(
          testParty.copyWith(
            participantIds: [userId, 'user_456'],
          ),
        );

        // Act
        await remoteDataSourceImpl.leaveWatchParty(
          userId: userId,
          partyId: testParty.id,
        );

        // Assert
        final updatedDoc = await getParty(testParty);
        final updatedParticipants = updatedDoc.data()?['participantIds'] as List;
        expect(updatedParticipants, isNot(contains(userId)));
        expect(updatedParticipants, contains('user_456'));
      },
    );
  });

  group('endWatchParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when endWatchParty is called '
      'then the watch party document should be deleted from Firestore',
      () async {
        // Arrange
        await createParty(testParty);
        final before = await getParty(testParty);
        expect(before.exists, isTrue);

        // Act
        await remoteDataSourceImpl.endWatchParty(partyId: testParty.id);

        // Assert
        final after = await getParty(testParty);
        expect(after.exists, isFalse);
      },
    );
  });

  group('listenToParticipants - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when listenToParticipants is called '
      'then it emits updated list of participantIds',
      () async {
        // Arrange
        const userA = 'user_A';
        const userB = 'user_B';

        final initialParty = testParty.copyWith(
          participantIds: [userA],
        );

        await createParty(initialParty);

        final stream = remoteDataSourceImpl.listenToParticipants(
          partyId: testParty.id,
        );

        // Act
        final updates = <List<String>>[];
        final sub = stream.listen(updates.add);

        // Simulate update
        await firestore
            .collection(
              FirebaseConstants.watchPartiesCollection,
            )
            .doc(testParty.id)
            .update({
          'participantIds': [userA, userB],
        });

        // Give Firestore time to emit
        await Future<dynamic>.delayed(const Duration(milliseconds: 100));
        await sub.cancel();

        // Assert
        expect(updates.first, contains(userA));
        expect(updates.last, containsAll([userA, userB]));
      },
    );
  });

  group('startParty - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when startParty is called '
      'then hasStarted field is set to true in Firestore',
      () async {
        // Arrange
        await createParty(testParty);

        // Act
        await remoteDataSourceImpl.startParty(partyId: testParty.id);

        // Assert
        final docSnapshot = await getParty(testParty);
        final hasStarted = docSnapshot.data()?['hasStarted'] as bool?;
        expect(hasStarted, isTrue);
      },
    );

    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when startParty is called for non-existent party '
      'then throws StartWatchPartyException',
      () async {
        // Arrange
        const nonExistentPartyId = 'non_existing_id';

        // Act
        final call = remoteDataSourceImpl.startParty;

        // Assert
        expect(
          () async => call(partyId: nonExistentPartyId),
          throwsA(isA<StartWatchPartyException>()),
        );
      },
    );
  });

  group('listenToPartyStart - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when listenToPartyStart is called '
      'then it emits initial and updated hasStarted values',
      () async {
        // Arrange
        await createParty(testParty);

        final updates = <bool>[];
        final stream = remoteDataSourceImpl.listenToPartyStart(
          partyId: testParty.id,
        );
        final sub = stream.listen(updates.add);

        await Future<dynamic>.delayed(const Duration(milliseconds: 100));

        // Act
        await firestore
            .collection(
              FirebaseConstants.watchPartiesCollection,
            )
            .doc(testParty.id)
            .update({
          'hasStarted': true,
        });

        await Future<dynamic>.delayed(const Duration(milliseconds: 100));

        await sub.cancel();

        // Simulate update

        // Assert
        // Assert
        expect(updates.length, greaterThanOrEqualTo(2));
        expect(updates.first, isFalse);
        expect(updates.last, isTrue);
      },
    );
  });

  group('updateVideoUrl - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when updateVideoUrl is called '
      'then it updates the videoUrl field in Firestore',
      () async {
        // Arrange
        await createParty(testParty);
        const newUrl = 'https://example.com/video';

        // Act
        await remoteDataSourceImpl.updateVideoUrl(
          partyId: testParty.id,
          newUrl: newUrl,
        );

        // Assert
        final updatedDoc = await getParty(testParty);
        expect(updatedDoc.data()?['videoUrl'], equals(newUrl));
      },
    );
  });

  group('sendSyncData - ', () {
    test(
      'given WatchPartyRemoteDataSourceImpl '
      'when sendSyncData is called '
      'then it updates playbackPosition, isPlaying, '
      'and lastSyncedTime in Firestore',
      () async {
        // Arrange
        await createParty(testParty);
        const testPosition = 123.45;
        const isPlaying = true;

        // Act
        await remoteDataSourceImpl.sendSyncData(
          partyId: testParty.id,
          playbackPosition: testPosition,
          isPlaying: isPlaying,
        );

        // Assert
        final updatedDoc = await getParty(testParty);
        expect(updatedDoc.data()?['playbackPosition'], equals(testPosition));
        expect(updatedDoc.data()?['isPlaying'], equals(isPlaying));
        expect(updatedDoc.data()?['lastSyncedTime'], isA<Timestamp>());
      },
    );
  });

  group('getSyncedData - ', () {});
}
