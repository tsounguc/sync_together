import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_public_watch_parties.dart';

part 'public_parties_state.dart';

class PublicPartiesCubit extends Cubit<WatchPartyListState> {
  PublicPartiesCubit(
    this._getPublicWatchParties,
  ) : super(WatchPartyListInitial());

  final GetPublicWatchParties _getPublicWatchParties;

  Future<void> fetchPublicParties() async {
    emit(WatchPartyListLoading());

    final result = await _getPublicWatchParties();

    result.fold(
      (failure) => emit(WatchPartyListError(failure.message)),
      (parties) => emit(WatchPartyListLoaded(parties)),
    );
  }
}
