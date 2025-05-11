import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class RemoveFriend extends UseCaseWithParams<void, RemoveFriendParams> {
  const RemoveFriend(this.repository);

  final FriendsRepository repository;

  @override
  ResultFuture<void> call(
    RemoveFriendParams params,
  ) =>
      repository.removeFriend(
        senderId: params.senderId,
        receiverId: params.receiverId,
      );
}

class RemoveFriendParams extends Equatable {
  const RemoveFriendParams({
    required this.senderId,
    required this.receiverId,
  });

  const RemoveFriendParams.empty()
      : senderId = '',
        receiverId = '';

  final String senderId;
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
