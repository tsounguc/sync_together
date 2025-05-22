import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class SendSyncData extends UseCaseWithParams<void, SendSyncDataParams> {
  const SendSyncData(this.repository);
  final WatchPartyRepository repository;

  @override
  ResultFuture<void> call(
    SendSyncDataParams params,
  ) =>
      repository.sendSyncData(
        partyId: params.partyId,
        playbackPosition: params.playbackPosition,
        isPlaying: params.isPlaying,
      );
}

class SendSyncDataParams extends Equatable {
  const SendSyncDataParams({
    required this.partyId,
    required this.playbackPosition,
    required this.isPlaying,
  });

  const SendSyncDataParams.empty()
      : partyId = '',
        playbackPosition = 0.0,
        isPlaying = false;

  final String partyId;
  final double playbackPosition;
  final bool isPlaying;

  @override
  List<Object?> get props => [partyId, playbackPosition, isPlaying];
}
