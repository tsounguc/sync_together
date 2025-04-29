import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this.remoteDataSource);

  final ChatRemoteDataSource remoteDataSource;

  @override
  ResultStream<List<Message>> listenToMessages({required String roomId}) {
    return remoteDataSource.listenToMessages(roomId: roomId).transform(
          StreamTransformer<List<MessageModel>, Either<Failure, List<Message>>>.fromHandlers(
            handleData: (messages, sink) {
              sink.add(Right(messages));
            },
            handleError: (error, stackTrace, sink) {
              debugPrint(stackTrace.toString());
              if (error is ListenToMessagesException) {
                sink.add(Left(ListenToMessagesFailure.fromException(error)));
              } else {
                sink.add(
                  Left(
                    ListenToMessagesFailure(
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
  ResultVoid sendMessage({required String roomId, required Message message}) async {
    try {
      final result = await remoteDataSource.sendMessage(
        roomId: roomId,
        message: message,
      );
      return Right(result);
    } on SendMessageException catch (e) {
      return Left(SendMessageFailure.fromException(e));
    }
  }
}
