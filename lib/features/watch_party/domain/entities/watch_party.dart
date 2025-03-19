import 'package:equatable/equatable.dart';

/// Represents a Watch Party session where users can watch a show together.
class WatchParty extends Equatable {
  /// Constructor for the [WatchParty].
  const WatchParty({
    required this.id,
    required this.hostId,
    required this.videoUrl,
    required this.title,
    required this.participantIds,
    required this.createdAt,
    required this.lastSyncedTime,
  });

  /// Unique ID of the watch party.
  final String id;

  /// The user ID of the host (creator of the watch party).
  final String hostId;

  /// The video URL that will be watched in sync.
  final String videoUrl;

  /// **Title of the watch party session.** (e.g., movie or show name)
  final String title;

  /// The list of participants (user IDs).
  final List<String> participantIds;

  /// Timestamp of when the watch party was created.
  final DateTime createdAt;

  /// The last synced playback time for the watch party.
  final DateTime lastSyncedTime;

  @override
  List<Object?> get props => [id, hostId, videoUrl, participantIds, createdAt];
}
