import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';

/// **Model for FriendRequest Entity**
///
/// This extends [FriendRequest] and includes JSON serialization methods.
class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.receiverId,
    required super.receiverName,
    required super.sentAt,
  });

  /// Represents an empty [FriendRequestModel] instance.
  ///
  /// Used for default values or initializing empty states.
  FriendRequestModel.empty()
      : this(
          id: '',
          senderId: '',
          senderName: '',
          receiverId: '',
          receiverName: '',
          sentAt: DateTime.now(),
        );

  /// Creates a [FriendRequestModel] from a JSON string.
  factory FriendRequestModel.fromJson(
    String source,
  ) =>
      FriendRequestModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  /// Creates a [FriendRequestModel] from a key-value map.
  FriendRequestModel.fromMap(DataMap dataMap)
      : this(
          id: dataMap['id'] as String,
          senderId: dataMap['senderId'] as String,
          senderName: dataMap['senderName'] as String,
          receiverId: dataMap['receiverId'] as String,
          receiverName: dataMap['receiverName'] as String,
          sentAt: (dataMap['sentAt'] as Timestamp).toDate(),
        );

  /// Converts a [FriendRequestModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [FriendRequestModel] instance to a key-value map.
  DataMap toMap() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'sentAt': Timestamp.fromDate(sentAt),
      };

  /// Creates a copy of the current [FriendRequestModel] with optional updates.
  FriendRequestModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    DateTime? sentAt,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
