import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

/// **Use Case: SetTypingStatus**
///
/// Calls the [ChatRepository] to set typing status.
class SetTypingStatus extends UseCaseWithParams<void, SetTypingStatusParams> {
  const SetTypingStatus(this.repository);

  final ChatRepository repository;

  @override
  ResultVoid call(SetTypingStatusParams params) => repository.setTypingStatus(
        roomId: params.roomId,
        userId: params.userId,
        userName: params.userName,
        isTyping: params.isTyping,
      );
}

/// **Parameters for setting typing status**
///
/// Includes  roomId, userId, userName, and typing status.
class SetTypingStatusParams extends Equatable {
  const SetTypingStatusParams({
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  /// Empty constructor for testing purposes
  const SetTypingStatusParams.empty()
      : this(
          roomId: '',
          userId: '',
          userName: '',
          isTyping: false,
        );

  final String roomId;
  final String userId;
  final String userName;
  final bool isTyping;

  @override
  List<Object?> get props => [
        roomId,
        userId,
        userName,
        isTyping,
      ];
}
