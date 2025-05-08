import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';

/// **Chat Repository Interface**
///
/// Handles messaging functionality during a watch party session.
/// Uses `ResultVoid` and `ResultStream` to handle success/failure outcomes.
abstract class ChatRepository {
  /// Sends a message to a specific room.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultVoid sendMessage({
    required String roomId,
    required Message message,
  });

  /// Listens to real-time message updates in a room.
  ///
  /// - **Success:** Returns a stream of messages.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultStream<List<Message>> listenToMessages({
    required String roomId,
  });

  /// Deletes a specific message.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultVoid deleteMessage({
    required String roomId,
    required String messageId,
  });

  /// Edits a previously sent message.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultVoid editMessage({
    required String roomId,
    required String messageId,
    required String newText,
  });

  /// Fetches the latest batch of messages without listening.
  ///
  /// - **Success:** Returns a list of messages.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultFuture<List<Message>> fetchMessages({
    required String roomId,
    int limit = 20,
  });

  /// Clears all messages in a room (e.g. for moderators).
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `MessageFailure`.
  ResultVoid clearRoomMessages({
    required String roomId,
  });
}
