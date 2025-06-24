import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class WatchPartyRepositoryImpl implements WatchPartyRepository {
  WatchPartyRepositoryImpl(this.remoteDataSource);

  final WatchPartyRemoteDataSource remoteDataSource;

  @override
  ResultFuture<WatchParty> createWatchParty({
    required WatchParty party,
  }) async {
    try {
      final result = await remoteDataSource.createWatchParty(party: party);
      return Right(result);
    } on CreateWatchPartyException catch (e) {
      return Left(CreateWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultFuture<WatchParty> joinWatchParty({
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
  ResultFuture<List<WatchParty>> getPublicWatchParties() async {
    try {
      final result = await remoteDataSource.getPublicWatchParties();
      return Right(result);
    } on GetPublicWatchPartiesException catch (e) {
      return Left(GetPublicWatchPartiesFailure.fromException(e));
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
  ResultVoid leaveWatchParty({
    required String userId,
    required String partyId,
  }) async {
    try {
      final result = await remoteDataSource.leaveWatchParty(
        userId: userId,
        partyId: partyId,
      );
      return Right(result);
    } on LeaveWatchPartyException catch (e) {
      return Left(LeaveWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultVoid endWatchParty({required String partyId}) async {
    try {
      final result = await remoteDataSource.endWatchParty(partyId: partyId);
      return Right(result);
    } on EndWatchPartyException catch (e) {
      return Left(EndWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultStream<List<String>> listenToParticipants({required String partyId}) {
    return remoteDataSource.listenToParticipants(partyId: partyId).transform(
          StreamTransformer<List<String>, Either<Failure, List<String>>>.fromHandlers(
            handleData: (participants, sink) {
              sink.add(Right(participants));
            },
            handleError: (error, stackTrace, sink) {
              if (error is ListenToParticipantsException) {
                sink.add(
                  Left(
                    ListenToParticipantsFailure.fromException(error),
                  ),
                );
              } else {
                sink.add(
                  Left(
                    ListenToParticipantsFailure(
                      message: error.toString(),
                      statusCode: 505,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  ResultVoid startParty({required String partyId}) async {
    try {
      final result = await remoteDataSource.startParty(partyId: partyId);
      return Right(result);
    } on StartWatchPartyException catch (e) {
      return Left(StartWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultStream<bool> listenToPartyStart({required String partyId}) {
    return remoteDataSource.listenToPartyStart(partyId: partyId).transform(
          StreamTransformer<bool, Either<Failure, bool>>.fromHandlers(
            handleData: (status, sink) {
              sink.add(Right(status));
            },
            handleError: (error, stackTrace, sink) {
              if (error is ListenToPartyStartException) {
                sink.add(Left(ListenToPartyStartFailure.fromException(error)));
              } else {
                sink.add(
                  Left(
                    ListenToPartyStartFailure(
                      message: error.toString(),
                      statusCode: 505,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  ResultVoid updateVideoUrl({
    required String partyId,
    required String newUrl,
  }) async {
    try {
      final result = await remoteDataSource.updateVideoUrl(
        partyId: partyId,
        newUrl: newUrl,
      );
      return Right(result);
    } on SyncWatchPartyException catch (e) {
      return Left(
        SyncWatchPartyFailure.fromException(e),
      );
    }
  }

  @override
  ResultVoid sendSyncData({
    required String partyId,
    required double playbackPosition,
    required bool isPlaying,
  }) async {
    try {
      final result = await remoteDataSource.sendSyncData(
        partyId: partyId,
        playbackPosition: playbackPosition,
        isPlaying: isPlaying,
      );
      return Right(result);
    } on SendSyncDataException catch (e) {
      return Left(
        SendSyncDataFailure.fromException(e),
      );
    }
  }

  @override
  ResultStream<DataMap> getSyncedData({required String partyId}) {
    return remoteDataSource.getSyncedData(partyId: partyId).transform(
          StreamTransformer<DataMap, Either<Failure, DataMap>>.fromHandlers(
            handleData: (status, sink) {
              sink.add(Right(status));
            },
            handleError: (error, stackTrace, sink) {
              if (error is GetSyncedDataException) {
                sink.add(Left(GetSyncedDataFailure.fromException(error)));
              } else {
                sink.add(
                  Left(
                    GetSyncedDataFailure(
                      message: error.toString(),
                      statusCode: 505,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }

  @override
  ResultFuture<UserEntity> getUserById(String uid) async {
    try {
      final result = await remoteDataSource.getUserById(uid);
      return Right(result);
    } on GetUserByIdException catch (e) {
      return Left(
        GetUserByIdFailure.fromException(e),
      );
    }
  }

  @override
  ResultStream<bool> listenToPartyExistence({required String partyId}) {
    return remoteDataSource.listenToPartyExistence(partyId: partyId).transform(
          StreamTransformer<bool, Either<Failure, bool>>.fromHandlers(
            handleData: (status, sink) {
              sink.add(Right(status));
            },
            handleError: (error, stackTrace, sink) {
              if (error is ListenToPartyExistenceException) {
                sink.add(
                  Left(
                    ListenToPartyExistenceFailure.fromException(error),
                  ),
                );
              } else {
                sink.add(
                  Left(
                    ListenToPartyExistenceFailure(
                      message: error.toString(),
                      statusCode: 505,
                    ),
                  ),
                );
              }
            },
          ),
        );
  }
}
