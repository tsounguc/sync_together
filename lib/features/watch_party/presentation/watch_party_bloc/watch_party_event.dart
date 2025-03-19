part of 'watch_party_bloc.dart';

/// Base event for watch party.
sealed class WatchPartyEvent extends Equatable {
  const WatchPartyEvent();
  @override
  List<Object?> get props => [];
}

/// Event to create a new watch party.
final class CreateWatchPartyEvent extends WatchPartyEvent {
  const CreateWatchPartyEvent({
    required this.title,
    required this.videoUrl,
    required this.hostId,
  });

  final String title;
  final String videoUrl;
  final String hostId;

  @override
  List<Object?> get props => [title, videoUrl, hostId];
}

/// Event to join an existing Watch Party
class JoinWatchPartyEvent extends WatchPartyEvent {
  const JoinWatchPartyEvent({
    required this.watchPartyId,
    required this.userId,
  });

  final String watchPartyId;
  final String userId;

  @override
  List<Object?> get props => [watchPartyId, userId];
}

/// Event to sync playback position across users
class SyncPlaybackEvent extends WatchPartyEvent {
  const SyncPlaybackEvent({
    required this.watchPartyId,
    required this.playbackPosition,
  });
  final String watchPartyId;
  final double playbackPosition;

  @override
  List<Object?> get props => [watchPartyId, playbackPosition];
}

/// Event to update watch party state
class UpdateWatchPartyEvent extends WatchPartyEvent {
  const UpdateWatchPartyEvent({
    required this.watchPartyId,
    required this.playbackPosition,
  });

  final String watchPartyId;
  final double playbackPosition;

  @override
  List<Object?> get props => [watchPartyId, playbackPosition];
}

/// Event to update watch party state
class GetWatchPartyEvent extends WatchPartyEvent {
  const GetWatchPartyEvent(
    this.watchPartyId,
  );

  final String watchPartyId;

  @override
  List<Object?> get props => [watchPartyId];
}
