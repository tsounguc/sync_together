part of 'watch_party_list_cubit.dart';

sealed class WatchPartyListState extends Equatable {
  const WatchPartyListState();

  @override
  List<Object?> get props => [];
}

final class WatchPartyListInitial extends WatchPartyListState {}

class WatchPartyListLoading extends WatchPartyListState {}

class WatchPartyListLoaded extends WatchPartyListState {
  const WatchPartyListLoaded(this.parties);

  final List<WatchParty> parties;

  @override
  List<Object?> get props => [parties];
}

class WatchPartyListError extends WatchPartyListState {
  const WatchPartyListError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
