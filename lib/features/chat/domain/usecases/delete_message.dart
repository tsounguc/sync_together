import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: DeleteMessage**
///
/// Calls the [ChatRepository] to delete a message.
class DeleteMessage extends UseCaseWithParams<void, DeleteMessageParams> {
  const DeleteMessage(this.repository);

  final ChatRepository repository;

  @override
  ResultVoid call(
    DeleteMessageParams params,
  ) =>
      repository.deleteMessage(
        roomId: params.roomId,
        messageId: params.messageId,
      );
}

/// **Parameters for deleting a message**
///
/// Includes an roomId and messageId.
class DeleteMessageParams extends Equatable {
  const DeleteMessageParams({
    required this.roomId,
    required this.messageId,
  });

  /// Empty constructor for testing purposes.
  const DeleteMessageParams.empty()
      : this(
          roomId: '',
          messageId: '',
        );

  final String roomId;
  final String messageId;

  @override
  List<Object?> get props => [roomId, messageId];
}
