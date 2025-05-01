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
    required this.party,
    this.onSuccess,
    this.onFailure,
  });

  final WatchPartyModel party;
  final void Function(WatchParty)? onSuccess;
  final void Function(String)? onFailure;

  @override
  List<Object?> get props => [party, onSuccess, onFailure];
}

/// Event to join an existing Watch Party
class JoinWatchPartyEvent extends WatchPartyEvent {
  const JoinWatchPartyEvent({
    required this.partyId,
    required this.userId,
  });

  final String partyId;
  final String userId;

  @override
  List<Object?> get props => [partyId, userId];
}

/// Event to sync playback position across users
class SyncPlaybackEvent extends WatchPartyEvent {
  const SyncPlaybackEvent({
    required this.watchPartyId,
    required this.playbackPosition,
    required this.isPlaying,
  });
  final String watchPartyId;
  final double playbackPosition;
  final bool isPlaying;

  @override
  List<Object?> get props => [watchPartyId, playbackPosition, isPlaying];
}

/// Event to get synced playback position across users
class GetSyncedDataEvent extends WatchPartyEvent {
  const GetSyncedDataEvent({
    required this.partyId,
  });
  final String partyId;

  @override
  List<Object?> get props => [partyId];
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

/// Event to update watch party video url state
class UpdateVideoUrlEvent extends WatchPartyEvent {
  const UpdateVideoUrlEvent({
    required this.watchPartyId,
    required this.newUrl,
  });

  final String watchPartyId;
  final String newUrl;

  @override
  List<Object?> get props => [watchPartyId, newUrl];
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

/// Event to start watch party
class StartPartyEvent extends WatchPartyEvent {
  const StartPartyEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// Event to listen for party starting
class ListenToStartPartyEvent extends WatchPartyEvent {
  const ListenToStartPartyEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}
