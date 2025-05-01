import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:sync_together/features/watch_party/domain/use_cases/update_video_url.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/watch_start_status.dart';

part 'watch_party_event.dart';
part 'watch_party_state.dart';

class WatchPartyBloc extends Bloc<WatchPartyEvent, WatchPartyState> {
  WatchPartyBloc(
      {required this.createWatchParty,
      required this.startParty,
      required this.getWatchParty,
      required this.joinWatchParty,
      required this.syncPlayback,
      required this.getSyncedData,
      required this.watchStartStatus,
      required this.updateVideoUrl})
      : super(const WatchPartyInitial()) {
    on<CreateWatchPartyEvent>(_onCreateWatchParty);
    on<StartPartyEvent>(_onStartWatchParty);
    on<GetWatchPartyEvent>(_onGetWatchParty);
    on<JoinWatchPartyEvent>(_onJoinWatchParty);
    on<SyncPlaybackEvent>(_onSyncPlayback);
    on<GetSyncedDataEvent>(_onGetSyncedData);
    on<ListenToStartPartyEvent>(_onListenToStartParty);
    on<UpdateVideoUrlEvent>(_onUpdateVideoUrl);
  }

  final CreateWatchParty createWatchParty;
  final StartWatchParty startParty;
  final GetWatchParty getWatchParty;
  final JoinWatchParty joinWatchParty;
  final SyncPlayback syncPlayback;
  final GetSyncedData getSyncedData;
  final WatchStartStatus watchStartStatus;
  final UpdateVideoUrl updateVideoUrl;

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
        isPlaying: event.isPlaying,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => emit(const SyncDataSent()),
    );
  }

  Future<void> _onUpdateVideoUrl(
    UpdateVideoUrlEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final result = await updateVideoUrl(
      UpdateVideoUrlParams(
        partyId: event.watchPartyId,
        newUrl: event.newUrl,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => debugPrint('Video URL updated in Firestore'),
    );
  }

  StreamSubscription<Either<Failure, DataMap>>? subscription;

  void _onGetSyncedData(
    GetSyncedDataEvent event,
    Emitter<WatchPartyState> emit,
  ) {
    subscription?.cancel();
    subscription = getSyncedData(event.partyId).listen(
      /*onData:*/
      (result) {
        result.fold(
          (failure) {
            emit(WatchPartyError(failure.message));
            subscription?.cancel();
          },
          (data) => emit(
            SyncUpdated(
              playbackPosition: data['playbackPosition'] as double? ?? 0,
              isPlaying: data['isPlaying'] as bool? ?? false,
            ),
          ),
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

  StreamSubscription<Either<Failure, bool>>? startPartySubscription;
  void _onListenToStartParty(
    ListenToStartPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) {
    startPartySubscription?.cancel();
    startPartySubscription = watchStartStatus(event.partyId).listen(
      /*onData*/ (result) {
        result.fold(
          (failure) {
            emit(WatchPartyError(failure.message));
            startPartySubscription?.cancel();
          },
          (hasStarted) {
            if (hasStarted) {
              emit(const PartyStartedRealtime());
              startPartySubscription?.cancel(); // Stop listening after party started
            }
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    startPartySubscription?.cancel();
    return super.close();
  }
}
