import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/usecases/listen_to_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/send_message.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.listenToMessages,
    required this.sendMessage,
  }) : super(const ChatInitial());

  final ListenToMessages listenToMessages;
  final SendMessage sendMessage;

  Future<void> sendTextMessage({required String roomId, required Message message}) async {
    emit(const MessageSending());
    final result = await sendMessage(
      SendMessageParams(
        roomId: roomId,
        message: message,
      ),
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (success) => emit(const MessageSent()),
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
