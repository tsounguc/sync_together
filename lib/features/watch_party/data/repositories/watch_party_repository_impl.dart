import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class WatchPartyRepositoryImpl implements WatchPartyRepository {
  WatchPartyRepositoryImpl(this.remoteDataSource);

  final WatchPartyRemoteDataSource remoteDataSource;

  @override
  ResultFuture<WatchParty> createWatchParty({
    required WatchPartyModel party,
  }) async {
    try {
      final result = await remoteDataSource.createWatchParty(party: party);
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
  ResultVoid startParty({required String partyId}) async {
    try {
      final result = await remoteDataSource.startParty(partyId: partyId);
      return Right(result);
    } on StartWatchPartyException catch (e) {
      return Left(StartWatchPartyFailure.fromException(e));
    }
  }

  @override
  ResultStream<bool> watchStartStatus({required String partyId}) {
    return remoteDataSource.watchStartStatus(partyId: partyId).transform(
          StreamTransformer<bool, Either<Failure, bool>>.fromHandlers(
            handleData: (status, sink) {
              sink.add(Right(status));
            },
            handleError: (error, stackTrace, sink) {
              debugPrint(stackTrace.toString());
              if (error is StartWatchPartyException) {
                sink.add(Left(StartWatchPartyFailure.fromException(error)));
              } else {
                sink.add(
                  Left(
                    StartWatchPartyFailure(
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
}
