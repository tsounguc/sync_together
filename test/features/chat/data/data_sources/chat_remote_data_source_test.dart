import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';

void main() {
  late FirebaseFirestore firestore;
  late ChatRemoteDataSourceImpl remoteDataSourceImpl;

  setUpAll(() {
    firestore = FakeFirebaseFirestore();
    remoteDataSourceImpl = ChatRemoteDataSourceImpl(firestore);
  });
  const testRoomId = '123';
  final testWatchParty = WatchPartyModel.empty().copyWith(id: testRoomId);

  Future<DocumentReference> sendMessage(MessageModel message, WatchPartyModel watchParty) async {
    return firestore
        .collection(FirebaseConstants.watchPartiesCollection)
        .doc(
          watchParty.id,
        )
        .collection(FirebaseConstants.messagesCollection)
        .add(message.toMap());
  }

  Future<QuerySnapshot<DataMap>> getMessages(
    WatchPartyModel watchParty,
  ) async =>
      firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(
            watchParty.id,
          )
          .collection(FirebaseConstants.messagesCollection)
          .get();

  group('sendMessage - ', () {
    test(
      'given ChatRemoteDataSourceImpl '
      'when [ChatRemoteDataSourceImpl.sendMessage] is called '
      'then upload [Message] to  watch party ',
      () async {
        // Arrange
        final message = MessageModel.empty()
            .copyWith(id: '1', senderId: 'sender_id', senderName: 'John Doe', text: 'hello world');

        // Act
        await remoteDataSourceImpl.sendMessage(
          roomId: testRoomId,
          message: message,
        );

        // Assert
        final messagesDocs = await getMessages(testWatchParty);

        expect(
          messagesDocs.docs,
          hasLength(1),
        );

        expect(
          messagesDocs.docs[0]['text'],
          equals(message.text),
        );
      },
    );
  });

  group('listenToMessages - ', () {
    test(
      'given ChatRemoteDataSourceImpl '
      'when [ChatRemoteDataSourceImpl.listenToMessages] call is successful '
      'then return [Stream<List<Message>>] ',
      () async {
        // Arrange
        // clear previous messages
        final messages = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .get();

        for (final doc in messages.docs) {
          await doc.reference.delete();
        }

        // Add messages
        await firestore
            .collection(
              FirebaseConstants.watchPartiesCollection,
            )
            .doc(testWatchParty.id)
            .set(testWatchParty.toMap());
        final expectedMessages = [
          MessageModel.empty(),
          MessageModel.empty().copyWith(
            id: '1',
            timestamp: DateTime.now().add(
              const Duration(seconds: 50),
            ),
          ),
        ];
        for (final message in expectedMessages) {
          await sendMessage(message, testWatchParty);
        }

        // Act
        final result = remoteDataSourceImpl.listenToMessages(roomId: testRoomId);

        // Assert
        expect(
          result,
          emitsInOrder([equals(expectedMessages)]),
        );
      },
    );

    test(
      'given ChatRemoteDataSourceImpl '
      'when [ChatRemoteDataSourceImpl.listenToMessages] is called and an error '
      'then return a stream of empty list ',
      () async {
        // Arrange
        // clear previous messages
        final messages = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .get();

        for (final doc in messages.docs) {
          await doc.reference.delete();
        }

        // Act
        final result = remoteDataSourceImpl.listenToMessages(roomId: testRoomId);

        // Assert
        expect(result, emits(equals(<MessageModel>[])));
      },
    );
  });

  group('deleteMessage - ', () {
    test(
      'given ChatRemoteDataSourceImpl ',
      () async {
        // Create messages sub-collection for current watch party
        final firstDocRef = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .add(MessageModel.empty().toMap());

        // Add a message to the sub-collection
        final message = MessageModel.empty().copyWith(id: '1');
        final docRef = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .add(message.toMap());

        final collection = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .get();
        // Assert that the message was added
        expect(
          collection.docs,
          hasLength(2),
        );

        // Act
        await remoteDataSourceImpl.deleteMessage(
          roomId: testRoomId,
          messageId: docRef.id,
        );
        final secondMessageDoc = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .doc(docRef.id)
            .get();
        final firstMessageDoc = await firestore
            .collection(FirebaseConstants.watchPartiesCollection)
            .doc(testWatchParty.id)
            .collection(FirebaseConstants.messagesCollection)
            .doc(firstDocRef.id)
            .get();

        // Assert that the second message was deleted
        expect(
          secondMessageDoc.exists,
          isFalse,
        );
        expect(
          firstMessageDoc.exists,
          isTrue,
        );
      },
    );
  });

  group('editMessage - ', () {
    test(
        'given ChatRemoteDataSourceImpl, '
        'when [ChatRemoteDataSourceImpl.editMessage] is called '
        'then change text of specific message and return [void]', () async {
      // Arrange
      const newText = 'hello my friends';
      final collection = await getMessages(testWatchParty);
      final messageId = collection.docs[0].id;

      // Act
      await remoteDataSourceImpl.editMessage(
        roomId: testRoomId,
        messageId: messageId,
        newText: newText,
      );
      final messageDoc = await firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(testWatchParty.id)
          .collection(FirebaseConstants.messagesCollection)
          .doc(messageId)
          .get();

      // Assert
      expect(
        messageDoc.data()!['text'],
        newText,
      );
    });
  });

  group('fetchMessages - ', () {
    test(
      'given ChatRemoteDataSourceImpl, '
      'when [ChatRemoteDataSourceImpl.fetchMessages] is called '
      'then fetch the latest batch of messages without listening ',
      () async {
        // Arrange
        // Act
        final result = await remoteDataSourceImpl.fetchMessages(roomId: testRoomId);
        // Assert
        expect(
          result,
          hasLength(1),
        );
      },
    );
  });

  group('clearRoomMessages - ', () {
    test(
      'given ChatRemoteDataSourceImpl, '
      'when [ChatRemoteDataSourceImpl.clearRoomMessages] is called '
      "then delete every message in the current watch party's sub-collection ",
      () async {
        // Arrange
        // Create messages sub-collection for current user
        for (var i = 0; i < 5; i++) {
          await sendMessage(
            MessageModel.empty().copyWith(id: i.toString()),
            testWatchParty,
          );
        }

        final collection = await getMessages(testWatchParty);
        // Assert that the messages were added
        expect(
          collection.docs,
          hasLength(6),
        );

        // Act
        await remoteDataSourceImpl.clearRoomMessages(roomId: testRoomId);
        final messagesDocs = await getMessages(testWatchParty);

        // Assert that the messages were deleted
        expect(
          messagesDocs.docs,
          isEmpty,
        );
      },
    );
  });
}
