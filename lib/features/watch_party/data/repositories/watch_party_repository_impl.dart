import 'package:dartz/dartz.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class WatchPartyRepositoryImpl implements WatchPartyRepository {
  WatchPartyRepositoryImpl(this.remoteDataSource);

  final WatchPartyRemoteDataSource remoteDataSource;

  @override
  ResultFuture<WatchParty> createWatchParty({
    required String hostId,
    required String videoUrl,
    required String title,
  }) async {
    try {
      final result = await remoteDataSource.createWatchParty(
        hostId: hostId,
        videoUrl: videoUrl,
        title: title,
      );
      return Right(result);
    } on CreateWatchPartyException catch (e) {
      return Left(CreateWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultFuture<WatchParty> getWatchParty(
    String partyId,
  ) async {
    try {
      final result = await remoteDataSource.getWatchParty(partyId);
      return Right(result);
    } on GetWatchPartyException catch (e) {
      return Left(GetWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultVoid joinWatchParty({
    required String partyId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.joinWatchParty(
        partyId: partyId,
        userId: userId,
      );
      return Right(result);
    } on JoinWatchPartyException catch (e) {
      return Left(JoinWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultVoid syncPlayback({
    required String partyId,
    required double playbackPosition,
  }) async {
    try {
      final result = await remoteDataSource.syncPlayback(
        partyId: partyId,
        playbackPosition: playbackPosition,
      );
      return Right(result);
    } on SyncWatchPartyException catch (e) {
      return Left(SyncWatchPartyFailure.fromException(e));
    }
  }
}
