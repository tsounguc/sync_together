import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/end_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_synced_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_user_by_id.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/leave_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_participants.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_party_existence.dart';
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
    required this.getUserById,
    required this.listenToPartyExistence,
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
    on<GetSyncedDataEvent>(
      _onGetSyncedData,
      transformer: restartable(),
    );
    on<ListenToPartyExistenceEvent>(
      _onWatchPartyEnded,
      transformer: restartable(),
    );

    on<_ParticipantsUpdatedReceived>(_handleParticipantsUpdated);

    on<_ParticipantsErrorReceived>((event, emit) {
      emit(WatchPartyError(event.message));
    });

    on<_PartyStartedRealtimeReceived>((event, emit) {
      emit(const PartyStartedRealtime());
    });

    on<_SyncedDataReceived>((event, emit) {
      emit(
        SyncUpdated(
          playbackPosition: event.data['playbackPosition'] as double? ?? 0,
          isPlaying: event.data['isPlaying'] as bool? ?? false,
        ),
      );
    });

    on<_PartyStartedErrorReceived>((event, emit) {
      emit(WatchPartyError(event.message));
    });

    on<_ParticipantProfilesResolved>((event, emit) {
      emit(ParticipantsProfilesUpdated(event.profiles));
    });

    on<_WatchPartyEndedRealtime>((event, emit) {
      emit(const WatchPartyEndedByHost());
    });
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
  final GetUserById getUserById;
  final ListenToPartyExistence listenToPartyExistence;

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
            add(_ParticipantsErrorReceived(failure.message));
          },
          (participants) {
            add(_ParticipantsUpdatedReceived(participants));
          },
        );
      },
      onError: (dynamic error) {
        add(_ParticipantsErrorReceived(error.toString()));
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
    emit(WatchPartyLoading());
    startPartySubscription?.cancel();

    startPartySubscription = listenToPartyStart(event.partyId).listen(
      (result) {
        result.fold(
          (failure) {
            add(_PartyStartedErrorReceived(failure.message));
          },
          (hasStarted) {
            if (hasStarted == true) {
              add(_PartyStartedRealtimeReceived(hasStarted: hasStarted));
            }
          },
        );
      },
      onError: (dynamic error) {
        add(_PartyStartedErrorReceived(error.toString()));
      },
      onDone: () => startPartySubscription?.cancel(),
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
      (_) => emit(VideoUrlUpdated()),
      // (_) => debugPrint('Video URL updated in Firestore'),
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
            debugPrint('[WatchPartySessionBloc] '
                'Firestore sync failure: ${failure.message}');
          },
          (data) {
            add(_SyncedDataReceived(data));
          },
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

  StreamSubscription<Either<Failure, bool>>? partyExistenceSubscription;

  void _onWatchPartyEnded(
    ListenToPartyExistenceEvent event,
    Emitter<WatchPartySessionState> emit,
  ) {
    partyExistenceSubscription?.cancel();

    partyExistenceSubscription = listenToPartyExistence(event.partyId).listen(
      /*onData:*/
      (result) {
        result.fold(
          (failure) {
            emit(WatchPartyError(failure.message));
            partyExistenceSubscription?.cancel();
            debugPrint('[WatchPartySessionBloc] '
                'Firestore sync failure: ${failure.message}');
          },
          (existence) {
            if (existence == false) {
              add(const _WatchPartyEndedRealtime());
            }
          },
        );
      },
      onError: (dynamic error) {
        emit(WatchPartyError(error.toString()));
        partyExistenceSubscription?.cancel();
      },
      onDone: () {
        partyExistenceSubscription?.cancel();
      },
    );
  }

  Future<void> _handleParticipantsUpdated(
    _ParticipantsUpdatedReceived event,
    Emitter<WatchPartySessionState> emit,
  ) async {
    final profiles = <UserEntity>[];

    for (final uid in event.participantIds) {
      final result = await getUserById(uid);
      result.fold(
        (failure) => debugPrint('Error fetching user $uid: ${failure.message}'),
        profiles.add,
      );
    }
    if (!isClosed) add(_ParticipantProfilesResolved(profiles));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    startPartySubscription?.cancel();
    _participantsSubscription?.cancel();
    partyExistenceSubscription?.cancel();
    return super.close();
  }
}

class _SyncedDataReceived extends WatchPartyEvent {
  const _SyncedDataReceived(this.data);

  final DataMap data;
}

class _ParticipantsUpdatedReceived extends WatchPartyEvent {
  const _ParticipantsUpdatedReceived(this.participantIds);

  final List<String> participantIds;
}

class _ParticipantsErrorReceived extends WatchPartyEvent {
  const _ParticipantsErrorReceived(this.message);

  final String message;
}

class _PartyStartedRealtimeReceived extends WatchPartyEvent {
  const _PartyStartedRealtimeReceived({required this.hasStarted});

  final bool hasStarted;
}

class _PartyStartedErrorReceived extends WatchPartyEvent {
  const _PartyStartedErrorReceived(this.message);

  final String message;
}

class _ParticipantProfilesResolved extends WatchPartyEvent {
  const _ParticipantProfilesResolved(this.profiles);

  final List<UserEntity> profiles;
}

class _WatchPartyEndedRealtime extends WatchPartyEvent {
  const _WatchPartyEndedRealtime();
}
