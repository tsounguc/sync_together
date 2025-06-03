import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

/// **Model for WatchParty Entity**
///
/// This extends [WatchParty] and includes JSON serialization methods.
class WatchPartyModel extends WatchParty {
  const WatchPartyModel({
    required super.id,
    required super.title,
    required super.videoUrl,
    required super.platform,
    required super.createdAt,
    required super.isPrivate,
    required super.hostId,
    required super.participantIds,
    required super.lastSyncedTime,
    required super.isPlaying,
    required super.hasStarted,
    required super.playbackPosition,
  });

  /// Represents an empty [WatchPartyModel] instance.
  ///
  /// Used for default values or initializing empty states.
  WatchPartyModel.empty()
      : this(
          id: '_empty.id',
          title: '_empty.title',
          videoUrl: '_empty.videoUrl',
          platform: const StreamingPlatformModel.empty(),
          createdAt: DateTime.utc(2025, 03, 03, 16, 45),
          isPrivate: false,
          hostId: '_empty.hostId',
          participantIds: [],
          lastSyncedTime: DateTime.utc(2025, 03, 03, 16, 45),
          isPlaying: false,
          hasStarted: false,
          playbackPosition: 0,
        );

  /// Creates a [WatchPartyModel] from a JSON string.
  factory WatchPartyModel.fromJson(String source) => WatchPartyModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  /// Creates a [WatchPartyModel] from a key-value map.
  WatchPartyModel.fromMap(DataMap dataMap)
      : this(
          id: dataMap['id'] as String,
          title: dataMap['title'] as String,
          videoUrl: dataMap['videoUrl'] as String,
          platform: dataMap['platform'] == null
              ? const StreamingPlatformModel.empty()
              : StreamingPlatformModel.fromMap(dataMap['platform'] as DataMap),
          createdAt: (dataMap['createdAt'] as Timestamp).toDate(),
          isPrivate: dataMap['isPrivate'] as bool,
          hostId: dataMap['hostId'] as String,
          participantIds: dataMap['participantIds'] == null
              ? []
              : List<String>.from(
                  dataMap['participantIds'] as List,
                ),
          lastSyncedTime: (dataMap['lastSyncedTime'] as Timestamp).toDate(),
          isPlaying: dataMap['isPlaying'] as bool,
          hasStarted: dataMap['hasStarted'] as bool,
          playbackPosition: double.parse(dataMap['playbackPosition'].toString()),
        );

  /// Converts a [WatchPartyModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [WatchPartyModel] instance to a key-value map.
  DataMap toMap() => {
        'id': id,
        'title': title,
        'videoUrl': videoUrl,
        'platform': (platform as StreamingPlatformModel).toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'isPrivate': isPrivate,
        'hostId': hostId,
        'participantIds': participantIds,
        'lastSyncedTime': Timestamp.fromDate(lastSyncedTime),
        'isPlaying': isPlaying,
        'hasStarted': hasStarted,
        'playbackPosition': playbackPosition,
      };

  /// Creates a copy of the current [WatchPartyModel] with optional updates.
  WatchPartyModel copyWith({
    String? id,
    String? title,
    String? videoUrl,
    StreamingPlatform? platform,
    DateTime? createdAt,
    bool? isPrivate,
    String? hostId,
    List<String>? participantIds,
    DateTime? lastSyncedTime,
    bool? isPlaying,
    bool? hasStarted,
    double? playbackPosition,
  }) {
    return WatchPartyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
      hostId: hostId ?? this.hostId,
      participantIds: participantIds ?? this.participantIds,
      lastSyncedTime: lastSyncedTime ?? this.lastSyncedTime,
      isPlaying: isPlaying ?? this.isPlaying,
      hasStarted: hasStarted ?? this.hasStarted,
      playbackPosition: playbackPosition ?? this.playbackPosition,
    );
  }
}
