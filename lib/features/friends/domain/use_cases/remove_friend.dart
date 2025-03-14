import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class RemoveFriendRequest extends UseCaseWithParams<void, RemoveFriendRequestParams> {
  const RemoveFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(RemoveFriendRequestParams params) => repository.removeFriend(
        senderId: params.senderId,
        receiverId: params.receiverId,
      );
}

class RemoveFriendRequestParams extends Equatable {
  const RemoveFriendRequestParams({
    required this.senderId,
    required this.receiverId,
  });

  const RemoveFriendRequestParams.empty()
      : senderId = '',
        receiverId = '';

  final String senderId;
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
