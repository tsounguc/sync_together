import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/sync_playback.dart';

part 'watch_party_event.dart';
part 'watch_party_state.dart';

class WatchPartyBloc extends Bloc<WatchPartyEvent, WatchPartyState> {
  WatchPartyBloc(
      {required this.createWatchParty,
      required this.getWatchParty,
      required this.joinWatchParty,
      required this.syncPlayback})
      : super(WatchPartyInitial()) {
    on<CreateWatchPartyEvent>(_onCreateWatchParty);
    on<GetWatchPartyEvent>(_onGetWatchParty);
    on<JoinWatchPartyEvent>(_onJoinWatchParty);
    on<SyncPlaybackEvent>(_onSyncPlayback);
  }

  final CreateWatchParty createWatchParty;
  final GetWatchParty getWatchParty;
  final JoinWatchParty joinWatchParty;
  final SyncPlayback syncPlayback;

  Future<void> _onCreateWatchParty(
    CreateWatchPartyEvent event,
    Emitter<WatchPartyState> emit,
  ) async {
    final result = await createWatchParty(
      CreateWatchPartyParams(
        title: event.title,
        videoUrl: event.videoUrl,
        hostId: event.hostId,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (watchParty) => emit(WatchPartyCreated(watchParty)),
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
        partyId: event.watchPartyId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(WatchPartyError(failure.message)),
      (success) => emit(const WatchPartyJoined()),
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
      (_) => emit(SyncUpdated(event.playbackPosition)),
    );
  }
}
