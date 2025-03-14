import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import '../../domain/entities/friend.dart';

/// **Model for Friend Entity**
///
/// This extends [Friend] and includes JSON serialization methods.
class FriendModel extends Friend {
  const FriendModel({
    required super.id,
    required super.user1Id,
    required super.user2Id,
    required super.createdAt,
  });

  /// Represents an empty [FriendModel] instance.
  ///
  /// Used for default values or initializing empty states.
  FriendModel.empty()
      : this(
    id: '',
    user1Id: '',
    user2Id: '',
    createdAt: DateTime.now(),
  );

  /// Creates a [FriendModel] from a JSON string.
  factory FriendModel.fromJson(String source) => FriendModel.fromMap(
    jsonDecode(source) as DataMap,
  );

  /// Creates a [FriendModel] from a key-value map.
  FriendModel.fromMap(DataMap dataMap)
      : this(
    id: dataMap['id'] as String,
    user1Id: dataMap['user1Id'] as String,
    user2Id: dataMap['user2Id'] as String,
    createdAt: (dataMap['createdAt'] as Timestamp).toDate(),
  );

  /// Converts a [FriendModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [FriendRequestModel] instance to a key-value map.
  DataMap toMap() => {
    'id': id,
    'user1Id': user1Id,
    'user2Id': user2Id,
    'createAt': Timestamp.fromDate(createdAt),
  };

  /// Creates a copy of the current [FriendModel] with optional updates.
  FriendModel copyWith({
    String? id,
    String? user1Id,
    String? user2Id,
    DateTime? createdAt,
  }) {
    return FriendModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
