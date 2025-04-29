import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

class ListenToMessages extends StreamUseCaseWithParams<List<Message>, String> {
  const ListenToMessages(this.repository);

  final ChatRepository repository;

  @override
  ResultStream<List<Message>> call(
    String params,
  ) =>
      repository.listenToMessages(roomId: params);
}
