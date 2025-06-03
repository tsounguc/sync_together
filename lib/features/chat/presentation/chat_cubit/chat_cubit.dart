import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/usecases/clear_room_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/delete_message.dart';
import 'package:sync_together/features/chat/domain/usecases/edit_message.dart';
import 'package:sync_together/features/chat/domain/usecases/fetch_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/listen_to_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/send_message.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.listenToMessages,
    required this.sendMessage,
    required this.editMessage,
    required this.deleteMessage,
    required this.fetchMessages,
    required this.clearRoomMessages,
  }) : super(const ChatInitial());

  final ListenToMessages listenToMessages;
  final SendMessage sendMessage;
  late EditMessage editMessage;
  late DeleteMessage deleteMessage;
  late FetchMessages fetchMessages;
  late ClearRoomMessages clearRoomMessages;

  Future<void> sendTextMessage({
    required String roomId,
    required Message message,
  }) async {
    emit(const MessageSending());
    final result = await sendMessage(
      SendMessageParams(
        roomId: roomId,
        message: message,
      ),
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) => debugPrint('Message sent successfully'),
    );
  }

  StreamSubscription<Either<Failure, List<Message>>>? _subscription;
  void listenToMessagesStream(String roomId) {
    emit(const ChatLoading());
    _subscription?.cancel();
    _subscription = listenToMessages(roomId).listen(
      /*onData*/
      (result) {
        result.fold(
          (failure) {
            emit(ChatError(failure.message));
            _subscription?.cancel();
          },
          (messages) => emit(MessagesReceived(messages)),
        );
      },
      onError: (dynamic error) {
        emit(ChatError(error.toString()));
        _subscription?.cancel();
      },
      onDone: () {
        _subscription?.cancel();
      },
    );
  }

  Future<void> editTextMessage({
    required String roomId,
    required String messageId,
    required String newText,
  }) async {
    emit(const MessageEditing());
    final result = await editMessage(
      EditMessageParams(
        roomId: roomId,
        messageId: messageId,
        newText: newText,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) => emit(const MessageEdited()),
    );
  }

  Future<void> deleteTextMessage({
    required String roomId,
    required String messageId,
  }) async {
    emit(const MessageDeleting());
    final result = await deleteMessage(
      DeleteMessageParams(
        roomId: roomId,
        messageId: messageId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) => debugPrint('Message deleted successfully'),
    );
  }

  Future<void> fetchTextMessages({
    required String roomId,
    int limit = 20,
  }) async {
    emit(const FetchingMessages());
    final result = await fetchMessages(
      FetchMessagesParams(
        roomId: roomId,
        limit: limit,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(MessagesFetched(messages)),
    );
  }

  Future<void> clearRoomTextMessages({
    required String roomId,
  }) async {
    emit(const MessagesClearing());
    final result = await clearRoomMessages(roomId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) => emit(const MessagesCleared()),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
