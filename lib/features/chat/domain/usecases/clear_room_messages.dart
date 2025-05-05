import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: ClearRoomMessages**
///
/// Calls the [ChatRepository] to clear all message in the room.
/// only for host or moderators.
class ClearRoomMessages extends UseCaseWithParams<void, String> {
  const ClearRoomMessages(this.repository);

  final ChatRepository repository;

  @override
  ResultVoid call(
    String params,
  ) =>
      repository.clearRoomMessages(roomId: params);
}
