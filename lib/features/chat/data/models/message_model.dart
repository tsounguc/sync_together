import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';

/// **Model for Message Entity**
///
/// This extends [Message] and includes JSON serialization methods.
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.timestamp,
  });

  /// Represents an empty [MessageModel] instance.
  ///
  /// Used for default values or initializing empty states.
  MessageModel.empty()
      : this(
          id: '_empty.id',
          senderId: '_empty.senderId',
          senderName: '_empty.senderName',
          text: '_empty.text',
          timestamp: DateTime.now(),
        );

  /// Creates a [MessageModel] from a JSON string.
  factory MessageModel.fromJson(String source) => MessageModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  /// Creates a [MessageModel] from a key-value map.
  MessageModel.fromMap(DataMap dataMap)
      : this(
          id: dataMap['id'] as String,
          senderId: dataMap['senderId'] as String,
          senderName: dataMap['senderName'] as String,
          text: dataMap['text'] as String,
          timestamp: (dataMap['timestamp'] as Timestamp).toDate(),
        );

  /// Converts a [MessageModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [MessageModel] instance to a key-value map.
  DataMap toMap() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  /// Creates a copy of the current [MessageModel] with optional updates.
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
