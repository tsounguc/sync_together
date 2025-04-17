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
  });
  final String watchPartyId;
  final double playbackPosition;

  @override
  List<Object?> get props => [watchPartyId, playbackPosition];
}

/// Event to get synced playback position across users
class GetSyncedDataEvent extends WatchPartyEvent {
  const GetSyncedDataEvent({
    required this.watchPartyId,
  });
  final String watchPartyId;

  @override
  List<Object?> get props => [watchPartyId];
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
