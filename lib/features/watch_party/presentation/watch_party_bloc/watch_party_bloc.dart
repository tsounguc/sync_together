import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_synced_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/start_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/sync_playback.dart';

part 'watch_party_event.dart';
part 'watch_party_state.dart';

class WatchPartyBloc extends Bloc<WatchPartyEvent, WatchPartyState> {
  WatchPartyBloc({
    required this.createWatchParty,
    required this.startParty,
    required this.getWatchParty,
    required this.joinWatchParty,
    required this.syncPlayback,
    required this.getSyncedData,
  }) : super(const WatchPartyInitial()) {
    on<CreateWatchPartyEvent>(_onCreateWatchParty);
    on<StartPartyEvent>(_onStartWatchParty);
    on<GetWatchPartyEvent>(_onGetWatchParty);
    on<JoinWatchPartyEvent>(_onJoinWatchParty);
    on<SyncPlaybackEvent>(_onSyncPlayback);
    on<GetSyncedDataEvent>(_onGetSyncedData);
  }

  final CreateWatchParty createWatchParty;
  final StartWatchParty startParty;
  final GetWatchParty getWatchParty;
  final JoinWatchParty joinWatchParty;
  final SyncPlayback syncPlayback;
  final GetSyncedData getSyncedData;

  Future<void> _onCreateWatchParty(
    CreateWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(WatchPartyLoading());

    final result = await createWatchParty(event.party);

    result.fold(
      (failure) {
        emit(WatchPartyError(failure.message));
        event.onFailure?.call(failure.message);
      },
      (createdParty) {
        emit(WatchPartyCreated(createdParty));
        event.onSuccess?.call(createdParty);
      },
    );
  }

  Future<void> _onStartWatchParty(
    StartPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    emit(WatchPartyLoading());
    final result = await startParty(event.partyId);
    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => emit(WatchPartyStarted()),
    );
  }

  Future<void> _onGetWatchParty(
    GetWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final result = await getWatchParty(
      event.watchPartyId,
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (watchParty) => emit(WatchPartyFetched(watchParty)),
    );
  }

  Future<void> _onJoinWatchParty(
    JoinWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final result = await joinWatchParty(
      JoinWatchPartyParams(
        partyId: event.partyId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (watchParty) => emit(WatchPartyJoined(watchParty)),
    );
  }

  Future<void> _onSyncPlayback(
    SyncPlaybackEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final result = await syncPlayback(
      SyncPlaybackParams(
        partyId: event.watchPartyId,
        playbackPosition: event.playbackPosition,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => emit(const SyncDataSent()),
    );
  }

  StreamSubscription<Either<Failure, DataMap>>? subscription;

  void _onGetSyncedData(GetSyncedDataEvent event, Emitter<WatchPartyState> emit) {
    subscription?.cancel();
    subscription = getSyncedData(event.watchPartyId).listen(
      /*onData:*/
      (result) {
        result.fold(
          (failure) {
            emit(WatchPartyError(failure.message));
            subscription?.cancel();
          },
          (data) => emit(SyncUpdated(data['playBackPosition'] as double)),
        );
      },
      onError: (dynamic error) {
        emit(WatchPartyError(error.toString()));
        subscription?.cancel();
      },
      onDone: () {
        subscription?.cancel();
      },
    );
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
