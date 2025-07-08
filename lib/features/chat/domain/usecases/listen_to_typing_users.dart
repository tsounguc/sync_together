import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: ListenToTypingUsers**
///
/// Calls the [ChatRepository] listen to typing users.
class ListenToTypingUsers
    extends StreamUseCaseWithParams<List<String>, String> {
  const ListenToTypingUsers(this.repository);

  final ChatRepository repository;

  @override
  ResultStream<List<String>> call(String params) =>
      repository.listenToTypingUsers(roomId: params);
}
