import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class SendFriendRequest extends UseCaseWithParams<void, SendFriendRequestParams> {
  const SendFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(SendFriendRequestParams params) => repository.sentFriendRequest(
        senderId: params.senderId,
        receivedId: params.receiverId,
      );
}

class SendFriendRequestParams extends Equatable {
  const SendFriendRequestParams({
    required this.senderId,
    required this.receiverId,
  });

  const SendFriendRequestParams.empty()
      : senderId = '',
        receiverId = '';

  final String senderId;
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
