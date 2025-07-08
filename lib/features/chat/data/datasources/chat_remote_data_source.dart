import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';

/// **Remote Data Source for Chat**
///
/// Handles all Firestore operations related to
/// creating, joining, and syncing watch parties.
abstract class ChatRemoteDataSource {
  /// Sends a new message session.
  ///
  /// - **Success:** Completes without return a value.
  /// - **Failure:** Throws a [MessageException].
  Future<void> sendMessage({
    required String roomId,
    required Message message,
  });

  /// Listen to message in watch party room
  ///
  /// - **Success:** Returns List of [Message].
  /// - **Failure:** Throws a [MessageException].
  Stream<List<MessageModel>> listenToMessages({required String roomId});

  /// Deletes a specific message.
  ///
  /// - **Success:** Returns void.
  /// - **Failure:** Throws a [MessageException].
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  });

  /// Edits a previously sent message.
  ///
  /// - **Success:** Returns void.
  /// - **Failure:** Throws a [MessageException].
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  });

  /// Fetches the latest batch of messages without listening.
  ///
  /// - **Success:** Returns a list of messages.
  /// - **Failure:** Throws a [MessageException].
  Future<List<MessageModel>> fetchMessages({
    required String roomId,
    int limit = 20,
  });

  /// Clears all messages in a room.
  ///
  /// - **Success:** Returns void.
  /// - **Failure:** Throws a [MessageException].
  Future<void> clearRoomMessages({
    required String roomId,
  });

  /// Updates typing status for a user in a specific room.
  ///
  /// - **Success:** Completes without return value.
  /// - **Failure:** Throws a [ChatException].
  Future<void> setTypingStatus({
    required String roomId,
    required String userId,
    required String userName,
    required bool isTyping,
  });

  /// Streams a list of names of users who are currently typing.
  ///
  /// - **Success:** Returns a stream of [List<String>].
  /// - **Failure:** Throws a [ChatException].
  Stream<List<String>> listenToTypingUsers({required String roomId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<MessageModel>> listenToMessages({required String roomId}) {
    final dataStream = _watchParties
        .doc(roomId)
        .collection(FirebaseConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageModel.fromMap(doc.data()),
              )
              .toList(),
        );

    return dataStream.handleError((dynamic error) {
      if (error is FirebaseException) {
        throw ListenToMessagesException(
          message: error.message ?? 'Unknown error occurred',
          statusCode: error.code,
        );
      }
      throw ListenToMessagesException(
        message: error.toString(),
        statusCode: '505',
      );
    });
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required Message message,
  }) async {
    try {
      final messageModel = MessageModel(
        id: message.id,
        senderId: message.senderId,
        senderName: message.senderName,
        text: message.text,
        timestamp: message.timestamp,
      );
      await _watchParties
          .doc(roomId)
          .collection(FirebaseConstants.messagesCollection)
          .doc(message.id)
          .set(messageModel.toMap());
    } on FirebaseAuthException catch (e) {
      throw SendMessageException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SendMessageException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> clearRoomMessages({required String roomId}) async {
    try {
      final query = firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(roomId)
          .collection(FirebaseConstants.messagesCollection);
      return _deleteMessagesByQuery(query);
    } on FirebaseException catch (e) {
      throw ClearRoomMessagesException(
        message: e.message ?? 'Unknown error occured',
        statusCode: e.code,
      );
    } on ClearRoomMessagesException {
      rethrow;
    } catch (e) {
      throw ClearRoomMessagesException(
        message: e.toString(),
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {
    try {
      await _watchParties
          .doc(roomId)
          .collection(
            FirebaseConstants.messagesCollection,
          )
          .doc(messageId)
          .delete();
    } on FirebaseException catch (e) {
      throw DeleteMessageException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.code,
      );
    } on DeleteMessageException {
      rethrow;
    } catch (e) {
      throw DeleteMessageException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    try {
      await firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(roomId)
          .collection(FirebaseConstants.messagesCollection)
          .doc(messageId)
          .update({'text': newText});
    } on FirebaseException catch (e) {
      throw EditMessageException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.code,
      );
    } on EditMessageException {
      rethrow;
    } catch (e) {
      throw EditMessageException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<List<MessageModel>> fetchMessages({
    required String roomId,
    int limit = 20,
  }) async {
    try {
      return await _watchParties
          .doc(roomId)
          .collection(
            FirebaseConstants.messagesCollection,
          )
          .limit(limit)
          .get()
          .then(
            (value) => value.docs
                .map(
                  (doc) => MessageModel.fromMap(doc.data()),
                )
                .toList(),
          );
    } on FirebaseException catch (e) {
      throw EditMessageException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.code,
      );
    } on EditMessageException {
      rethrow;
    } catch (e) {
      throw EditMessageException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> setTypingStatus({
    required String roomId,
    required String userId,
    required String userName,
    required bool isTyping,
  }) async {
    try {
      await firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(roomId)
          .collection('typing_status')
          .doc(userId)
          .set({
        'isTyping': isTyping,
        'name': userName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw SetTypingStatusException(
        message: e.message ?? 'Failed to set typing status',
        statusCode: e.code,
      );
    } catch (e) {
      throw SetTypingStatusException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Stream<List<String>> listenToTypingUsers({required String roomId}) {
    try {
      return firestore
          .collection(FirebaseConstants.watchPartiesCollection)
          .doc(roomId)
          .collection('typing_status')
          .where('isTyping', isEqualTo: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => doc['name'] as String).toList());
    } catch (e) {
      throw ListenToTypingUsersException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  Future<void> _deleteMessagesByQuery(Query query) async {
    final messages = await query.get();
    if (messages.docs.length > 500) {
      for (var i = 0; i < messages.docs.length; i += 500) {
        final batch = firestore.batch();
        final end = i + 500;
        final messagesBatch = messages.docs.sublist(
          i,
          end > messages.docs.length ? messages.docs.length : end,
        );
        for (final message in messagesBatch) {
          batch.delete(message.reference);
        }
        await batch.commit();
      }
    } else {
      final batch = firestore.batch();
      for (final message in messages.docs) {
        batch.delete(message.reference);
      }
      await batch.commit();
    }
  }

  CollectionReference<DataMap> get _watchParties => firestore.collection(
        FirebaseConstants.watchPartiesCollection,
      );
}
