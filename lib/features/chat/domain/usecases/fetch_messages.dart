import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: FetchMessages**
///
/// Calls the [ChatRepository] to fetch the latest
/// batch of messages without listening.
class FetchMessages extends UseCaseWithParams<List<Message>, FetchMessagesParams> {
  const FetchMessages(this.repository);
  final ChatRepository repository;

  @override
  ResultFuture<List<Message>> call(
    FetchMessagesParams params,
  ) =>
      repository.fetchMessages(
        roomId: params.roomId,
        limit: params.limit,
      );
}

/// **Parameters for fetching messages**
///
/// Includes a roomId and limit.
class FetchMessagesParams extends Equatable {
  const FetchMessagesParams({
    required this.roomId,
    required this.limit,
  });

  /// Empty constructor for testing purposes
  const FetchMessagesParams.empty()
      : this(
          roomId: '',
          limit: 20,
        );

  final String roomId;
  final int limit;

  @override
  List<Object?> get props => [roomId, limit];
}
