import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class RejectFriendRequest extends UseCaseWithParams<void, RejectFriendRequestParams> {
  const RejectFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(RejectFriendRequestParams params) => repository.rejectFriendRequest(
        senderId: params.senderId,
        receivedId: params.receiverId,
      );
}

class RejectFriendRequestParams extends Equatable {
  const RejectFriendRequestParams({
    required this.senderId,
    required this.receiverId,
  });

  const RejectFriendRequestParams.empty()
      : senderId = '',
        receiverId = '';

  final String senderId;
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
