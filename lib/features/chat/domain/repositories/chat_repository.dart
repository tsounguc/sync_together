import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  ResultVoid sendMessage({
    required String roomId,
    required Message message,
  });

  ResultStream<List<Message>> listenToMessages({
    required String roomId,
  });
}
