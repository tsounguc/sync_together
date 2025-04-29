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
/// Handles all Firestore operations related to creating, joining, and syncing watch parties.
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
  Stream<List<Message>> listenToMessages({required String roomId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Stream<List<Message>> listenToMessages({required String roomId}) {
    final dataStream = _watchParties
        .doc(roomId)
        .collection(FirebaseConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => MessageModel.fromMap(doc.data()),
            )
            .toList());

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
  Future<void> sendMessage({required String roomId, required Message message}) async {
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

  CollectionReference<DataMap> get _watchParties => firestore.collection(
        FirebaseConstants.watchPartiesCollection,
      );
}
