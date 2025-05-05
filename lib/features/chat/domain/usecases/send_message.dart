import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: SendMessage**
///
/// Calls the [ChatRepository] to send message.
class SendMessage extends UseCaseWithParams<void, SendMessageParams> {
  const SendMessage(this.repository);

  final ChatRepository repository;

  @override
  ResultFuture<void> call(
    SendMessageParams params,
  ) =>
      repository.sendMessage(
        roomId: params.roomId,
        message: params.message,
      );
}

/// **Parameters for sending a message**
///
/// Includes an roomId and message.
class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.roomId,
    required this.message,
  });

  /// Empty constructor for testing purposes.
  SendMessageParams.empty()
      : this(
          roomId: '',
          message: Message.empty(),
        );

  final String roomId;
  final Message message;

  @override
  List<Object?> get props => [roomId, message];
}
