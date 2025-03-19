part of 'watch_party_bloc.dart';

/// Base state for watch party.
sealed class WatchPartyState extends Equatable {
  const WatchPartyState();
  @override
  List<Object?> get props => [];
}

/// Initial state
final class WatchPartyInitial extends WatchPartyState {
  const WatchPartyInitial();
}

/// Error state
class WatchPartyError extends WatchPartyState {
  const WatchPartyError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Success state for creating watch party
final class WatchPartyCreated extends WatchPartyState {
  const WatchPartyCreated(this.watchParty);

  final WatchParty watchParty;

  @override
  List<Object?> get props => [watchParty];
}

/// Success state for joining watch party
class WatchPartyJoined extends WatchPartyState {
  const WatchPartyJoined();
}

/// Success state for getting watch party
class WatchPartyFetched extends WatchPartyState {
  const WatchPartyFetched(this.watchParty);
  final WatchParty watchParty;

  @override
  List<Object?> get props => [watchParty];
}

/// Success state for syncing playback
class SyncUpdated extends WatchPartyState {
  const SyncUpdated(this.playbackPosition);

  final double playbackPosition;

  @override
  List<Object?> get props => [playbackPosition];
}
