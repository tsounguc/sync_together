import 'package:equatable/equatable.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

/// Represents a Watch Party session where users can watch a show together.
class WatchParty extends Equatable {
  /// Constructor for the [WatchParty].
  const WatchParty({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.platform,
    required this.createdAt,
    required this.isPrivate,
    required this.hostId,
    required this.participantIds,
    required this.lastSyncedTime,
    required this.isPlaying,
    required this.playbackPosition,
  });

  /// Empty Constructor for the [WatchParty].
  WatchParty.empty()
      : this(
          id: '',
          title: '',
          videoUrl: '',
          platform: StreamingPlatform.empty(),
          createdAt: DateTime.now(),
          isPrivate: false,
          hostId: '',
          participantIds: ['1'],
          lastSyncedTime: DateTime.now(),
          isPlaying: false,
          playbackPosition: 0,
        );

  /// Unique ID of the watch party.
  final String id;

  /// The user ID of the host (creator of the watch party).
  final String hostId;

  /// The video URL that will be watched in sync.
  final String videoUrl;

  /// The selected streaming platform for this watch party.
  final StreamingPlatform platform;

  /// **Title of the watch party session.** (e.g., movie or show name)
  final String title;

  /// The list of participants (user IDs).
  final List<String> participantIds;

  /// Timestamp of when the watch party was created.
  final DateTime createdAt;

  /// Flag to determine privacy of watch party
  final bool isPrivate;

  /// The last synced playback time for the watch party.
  final DateTime lastSyncedTime;

  /// The current playback position
  final double playbackPosition;

  /// Flag to indicate if video currently playing
  final bool isPlaying;

  @override
  List<Object?> get props => [
        id,
        hostId,
        videoUrl,
        platform,
        participantIds,
        createdAt,
        isPlaying,
        isPrivate,
        playbackPosition,
      ];
}
