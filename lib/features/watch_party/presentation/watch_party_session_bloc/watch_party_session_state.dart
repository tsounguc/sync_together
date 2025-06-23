part of 'watch_party_session_bloc.dart';

/// Base state for watch party.
sealed class WatchPartySessionState extends Equatable {
  const WatchPartySessionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class WatchPartySessionInitial extends WatchPartySessionState {
  const WatchPartySessionInitial();
}

/// Error state
class WatchPartyError extends WatchPartySessionState {
  const WatchPartyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Loading state
class WatchPartyLoading extends WatchPartySessionState {}

/// Success state for creating watch party
final class WatchPartyCreated extends WatchPartySessionState {
  const WatchPartyCreated(this.party);

  final WatchParty party;

  @override
  List<Object?> get props => [party];
}

/// Success state for joining watch party
class WatchPartyJoined extends WatchPartySessionState {
  const WatchPartyJoined(this.party);

  final WatchParty party;

  @override
  List<Object?> get props => [party];
}

/// Success state for getting watch party
class WatchPartyFetched extends WatchPartySessionState {
  const WatchPartyFetched(this.watchParty);

  final WatchParty watchParty;

  @override
  List<Object?> get props => [watchParty];
}

/// Success state for getting watch party
class WatchPartyLeft extends WatchPartySessionState {
  const WatchPartyLeft();
}

/// Success state for ending watch party
class WatchPartyEnded extends WatchPartySessionState {
  const WatchPartyEnded();
}

/// Success state for when host ends watch party
class WatchPartyEndedByHost extends WatchPartySessionState {
  const WatchPartyEndedByHost();
}

/// Success state for syncing playback
class SyncDataSent extends WatchPartySessionState {
  const SyncDataSent();
}

/// Success state for syncing playback
class SyncUpdated extends WatchPartySessionState {
  const SyncUpdated({
    required this.playbackPosition,
    required this.isPlaying,
  });

  final double playbackPosition;
  final bool isPlaying;

  @override
  List<Object?> get props => [playbackPosition, isPlaying];
}

/// Success state for syncing playback
class ParticipantsUpdated extends WatchPartySessionState {
  const ParticipantsUpdated(this.participantIds);

  final List<String> participantIds;

  @override
  List<Object?> get props => [participantIds];
}

/// Success state for updateing watch party url
class VideoUrlUpdated extends WatchPartySessionState {}

/// Success state for starting a watch party
class WatchPartyStarted extends WatchPartySessionState {}

/// Success state for when started real-time detected
class PartyStartedRealtime extends WatchPartySessionState {
  const PartyStartedRealtime();
}

class ParticipantsProfilesUpdated extends WatchPartySessionState {
  const ParticipantsProfilesUpdated(this.profiles);

  final List<UserEntity> profiles;

  @override
  List<Object?> get props => [profiles];
}
