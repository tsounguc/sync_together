import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: EditMessage**
///
/// Calls the [ChatRepository] to edit a message.
class EditMessage extends UseCaseWithParams<void, EditMessageParams> {
  const EditMessage(this.repository);
  final ChatRepository repository;
  @override
  ResultVoid call(EditMessageParams params) => repository.editMessage(
        roomId: params.roomId,
        messageId: params.messageId,
        newText: params.messageId,
      );
}

/// **Parameters for editing a message**
///
/// Includes an roomId, messageId, and the new text.
class EditMessageParams extends Equatable {
  const EditMessageParams({
    required this.roomId,
    required this.messageId,
    required this.newText,
  });

  /// Empty constructor for testing purposes
  const EditMessageParams.empty()
      : this(
          roomId: '',
          messageId: '',
          newText: '',
        );

  final String roomId;
  final String messageId;
  final String newText;

  @override
  List<Object?> get props => [roomId, messageId, newText];
}
