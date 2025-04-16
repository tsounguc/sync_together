import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/domain/repositories/sync_playback_service.dart';

class WebRTCPlaybackSync implements SyncPlaybackService {
  WebRTCPlaybackSync(this.remoteDataSource);

  final WatchPartyRemoteDataSource remoteDataSource;

  @override
  ResultStream<DataMap> getSyncedData({required String roomId}) {
    return remoteDataSource.getSyncedData(partyId: roomId).transform(
          StreamTransformer<DataMap, Either<Failure, DataMap>>.fromHandlers(
            handleData: (syncedData, sink) {
              sink.add(Right(syncedData));
            },
            handleError: (error, stackTrace, sink) {
              debugPrint(stackTrace.toString());
              if (error is SyncWatchPartyException) {
                sink.add(Left(SyncWatchPartyFailure.fromException(error)));
              } else {
                sink.add(
                  Left(
                    SyncWatchPartyFailure(
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
  ResultVoid sendSyncData({
    required String roomId,
    required double playbackPosition,
  }) async {
    try {
      final result = await remoteDataSource.sendSyncData(
        partyId: roomId,
        playbackPosition: playbackPosition,
      );
      return Right(result);
    } on SyncWatchPartyException catch (e) {
      return Left(SyncWatchPartyFailure.fromException(e));
    }
  }
}
