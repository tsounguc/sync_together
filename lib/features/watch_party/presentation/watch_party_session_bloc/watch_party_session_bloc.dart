import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/end_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_synced_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/leave_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_participants.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_party_start.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/send_sync_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/start_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/update_video_url.dart';

part 'watch_party_session_event.dart';
part 'watch_party_session_state.dart';

class WatchPartySessionBloc extends Bloc<WatchPartyEvent, WatchPartySessionState> {
  WatchPartySessionBloc({
    required this.createWatchParty,
    required this.joinWatchParty,
    required this.getWatchParty,
    required this.leaveWatchParty,
    required this.endWatchParty,
    required this.listenToParticipants,
    required this.startParty,
    required this.listenToPartyStart,
    required this.updateVideoUrl,
    required this.sendSyncData,
    required this.getSyncedData,
  }) : super(const WatchPartySessionInitial()) {
    on<CreateWatchPartyEvent>(_onCreateWatchParty);
    on<JoinWatchPartyEvent>(_onJoinWatchParty);
    on<GetWatchPartyEvent>(_onGetWatchParty);
    on<LeaveWatchPartyEvent>(_onLeaveWatchParty);
    on<EndWatchPartyEvent>(_onEndWatchParty);
    on<ListenToParticipantsEvent>(
      _onListenToParticipants,
      transformer: restartable(),
    );
    on<StartPartyEvent>(_onStartWatchParty);
    on<ListenToPartyStartEvent>(
      _onListenToStartParty,
      transformer: restartable(),
    );
    on<UpdateVideoUrlEvent>(_onUpdateVideoUrl);
    on<SendSyncDataEvent>(_onSendSyncData);
    on<GetSyncedDataEvent>(_onGetSyncedData);
  }

  final CreateWatchParty createWatchParty;
  final JoinWatchParty joinWatchParty;
  final GetWatchParty getWatchParty;
  final LeaveWatchParty leaveWatchParty;
  final EndWatchParty endWatchParty;
  final ListenToParticipants listenToParticipants;
  final StartWatchParty startParty;
  final ListenToPartyStart listenToPartyStart;
  final UpdateVideoUrl updateVideoUrl;
  final SendSyncData sendSyncData;
  final GetSyncedData getSyncedData;

  Future<void> _onCreateWatchParty(
    CreateWatchPartyEvent event,
    Emitter<WatchPartySessionState> emit,
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

  Future<void> _onJoinWatchParty(
    JoinWatchPartyEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    emit(WatchPartyLoading());
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

  Future<void> _onGetWatchParty(
    GetWatchPartyEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    emit(WatchPartyLoading());
    final result = await getWatchParty(
      event.partyId,
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (watchParty) => emit(WatchPartyFetched(watchParty)),
    );
  }

  Future<void> _onLeaveWatchParty(
    LeaveWatchPartyEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    emit(WatchPartyLoading());
    final result = await leaveWatchParty(
      LeaveWatchPartyParams(
        partyId: event.partyId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (success) => emit(const WatchPartyLeft()),
    );
  }

  Future<void> _onEndWatchParty(
    EndWatchPartyEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    emit(WatchPartyLoading());

    final result = await endWatchParty(event.partyId);

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (success) => emit(const WatchPartyEnded()),
    );
  }

  StreamSubscription<Either<Failure, List<String>>>? _participantsSubscription;
  void _onListenToParticipants(
    ListenToParticipantsEvent event,
    Emitter<WatchPartySessionState> emit,
  ) {
    emit(WatchPartyLoading());
    _participantsSubscription?.cancel();

    _participantsSubscription = listenToParticipants(event.partyId).listen(
      (result) {
        result.fold(
          (failure) {
            emit(WatchPartyError(failure.message));
          },
          (participants) {
            emit(ParticipantsUpdated(participants));
          },
        );
      },
      onError: (error) {
        emit(WatchPartyError(error.toString()));
      },
      onDone: () => _participantsSubscription?.cancel(),
    );
  }

  Future<void> _onStartWatchParty(
    StartPartyEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    debugPrint('[GUEST LISTENER] Got party start event: ${event.partyId}');
    emit(WatchPartyLoading());
    final result = await startParty(event.partyId);
    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => emit(WatchPartyStarted()),
    );
  }

  StreamSubscription<Either<Failure, bool>>? startPartySubscription;
  void _onListenToStartParty(
    ListenToPartyStartEvent event,
    Emitter<WatchPartySessionState> emit,
  ) {
    startPartySubscription?.cancel();

    emit(WatchPartyLoading());

    startPartySubscription = listenToPartyStart(event.partyId).listen(
      /*onData*/ (result) {
        if (emit.isDone) return;

        result.fold(
          (failure) {
            if (!emit.isDone) emit(WatchPartyError(failure.message));
            startPartySubscription?.cancel();
          },
          (hasStarted) {
            if (hasStarted && !emit.isDone) {
              emit(const PartyStartedRealtime());
              startPartySubscription?.cancel();
            }

            // Stop listening after party started
          },
        );
      },
      onError: (dynamic error) {
        if (!emit.isDone) {
          emit(WatchPartyError(error.toString()));
        }
        startPartySubscription?.cancel();
      },
      // onDone: () {
      //   startPartySubscription?.cancel();
      // },
    );
  }

  Future<void> _onUpdateVideoUrl(
    UpdateVideoUrlEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    final result = await updateVideoUrl(
      UpdateVideoUrlParams(
        partyId: event.partyId,
        newUrl: event.newUrl,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (_) => debugPrint('Video URL updated in Firestore'),
    );
  }

  Future<void> _onSendSyncData(
    SendSyncDataEvent event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    final result = await sendSyncData(
      SendSyncDataParams(
        partyId: event.partyId,
        playbackPosition: event.playbackPosition,
        isPlaying: event.isPlaying,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (success) => null,
    );
  }

  StreamSubscription<Either<Failure, DataMap>>? subscription;
  void _onGetSyncedData(
    GetSyncedDataEvent event,
    Emitter<WatchPartySessionState> emit,
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

  @override
  Future<void> close() {
    subscription?.cancel();
    startPartySubscription?.cancel();
    _participantsSubscription?.cancel();
    return super.close();
  }
}
