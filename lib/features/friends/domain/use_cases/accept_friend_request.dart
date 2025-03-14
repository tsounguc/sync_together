import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class AcceptFriendRequest extends UseCaseWithParams<void, AcceptFriendRequestParams> {
  const AcceptFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(AcceptFriendRequestParams params) => repository.acceptFriendRequest(
        senderId: params.senderId,
        receivedId: params.receiverId,
      );
}

class AcceptFriendRequestParams extends Equatable {
  const AcceptFriendRequestParams({
    required this.senderId,
    required this.receiverId,
  });

  const AcceptFriendRequestParams.empty()
      : senderId = '',
        receiverId = '';

  final String senderId;
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
