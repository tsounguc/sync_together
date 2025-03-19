import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

/// **Model for WatchParty Entity**
///
/// This extends [WatchParty] and includes JSON serialization methods.
class WatchPartyModel extends WatchParty {
  const WatchPartyModel({
    required super.id,
    required super.hostId,
    required super.videoUrl,
    required super.title,
    required super.participantIds,
    required super.createdAt,
    required super.lastSyncedTime,
  });

  /// Represents an empty [WatchPartyModel] instance.
  ///
  /// Used for default values or initializing empty states.
  WatchPartyModel.empty()
      : this(
          id: '',
          hostId: '',
          videoUrl: '',
          title: '',
          participantIds: [],
          createdAt: DateTime.now(),
          lastSyncedTime: DateTime(0, 0, 0),
        );

  /// Creates a [WatchPartyModel] from a JSON string.
  factory WatchPartyModel.fromJson(String source) => WatchPartyModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  /// Creates a [WatchPartyModel] from a key-value map.
  WatchPartyModel.fromMap(DataMap dataMap)
      : this(
          id: dataMap['id'] as String,
          hostId: dataMap['hostId'] as String,
          videoUrl: dataMap['videoUrl'] as String,
          title: dataMap['title'] as String,
          participantIds: dataMap['participantIds'] == null
              ? List<String>.from(
                  dataMap['participantIds'] as List,
                )
              : [],
          createdAt: (dataMap['createdAt'] as Timestamp).toDate(),
          lastSyncedTime: (dataMap['lastSyncedTime'] as Timestamp).toDate(),
        );

  /// Converts a [WatchPartyModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [WatchPartyModel] instance to a key-value map.
  DataMap toMap() => {
        'id': id,
        'hostId': hostId,
        'videoUrl': videoUrl,
        'title': title,
        'participantIds': participantIds,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastSyncedTime': Timestamp.fromDate(lastSyncedTime),
      };

  /// Creates a copy of the current [WatchPartyModel] with optional updates.
  WatchPartyModel copyWith({
    String? id,
    String? hostId,
    String? videoUrl,
    String? title,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? lastSyncedTime,
  }) {
    return WatchPartyModel(
      id: id ?? this.id,
      hostId: hostId ?? this.hostId,
      videoUrl: videoUrl ?? this.videoUrl,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
    );
  }
}
