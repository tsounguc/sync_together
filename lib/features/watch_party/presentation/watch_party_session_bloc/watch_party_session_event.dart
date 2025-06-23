part of 'watch_party_session_bloc.dart';

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

  final WatchParty party;
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
    required this.partyId,
    required this.newUrl,
  });

  final String partyId;
  final String newUrl;

  @override
  List<Object?> get props => [partyId, newUrl];
}

/// Event to get watch party state
class GetWatchPartyEvent extends WatchPartyEvent {
  const GetWatchPartyEvent(
    this.partyId,
  );

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// Event to leave watch party
class LeaveWatchPartyEvent extends WatchPartyEvent {
  const LeaveWatchPartyEvent({
    required this.partyId,
    required this.userId,
  });

  final String partyId;
  final String userId;

  @override
  List<Object?> get props => [partyId, userId];
}

/// Event to end watch party state
class EndWatchPartyEvent extends WatchPartyEvent {
  const EndWatchPartyEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// Event to listen to party existence
class ListenToPartyExistenceEvent extends WatchPartyEvent {
  const ListenToPartyExistenceEvent(this.partyId);

  final String partyId;
}

/// Event to listen to participants watch party
class ListenToParticipantsEvent extends WatchPartyEvent {
  const ListenToParticipantsEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// Event to start watch party
class StartPartyEvent extends WatchPartyEvent {
  const StartPartyEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}

/// Event to send playback position and playing status watch party
class SendSyncDataEvent extends WatchPartyEvent {
  const SendSyncDataEvent({
    required this.partyId,
    required this.playbackPosition,
    required this.isPlaying,
  });

  final String partyId;
  final double playbackPosition;
  final bool isPlaying;

  @override
  List<Object?> get props => [
        partyId,
        playbackPosition,
        isPlaying,
      ];
}

/// Event to listen for party starting
class ListenToPartyStartEvent extends WatchPartyEvent {
  const ListenToPartyStartEvent(this.partyId);

  final String partyId;

  @override
  List<Object?> get props => [partyId];
}
