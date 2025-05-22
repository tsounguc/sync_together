import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

/// **Use Case: Remove friend**
///
/// Calls the [FriendsRepository] to remove user from friends list.
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

/// **Parameters for Remove Friend**
///
/// Includes an senderId and receiverId.
class RemoveFriendParams extends Equatable {
  const RemoveFriendParams({
    required this.senderId,
    required this.receiverId,
  });

  /// Empty constructor for testing purposes.
  const RemoveFriendParams.empty()
      : senderId = '',
        receiverId = '';

  /// Unique ID of user who initially sent friend request for friendship
  final String senderId;

  /// Unique ID of user who received friend requewst
  final String receiverId;

  @override
  List<Object?> get props => [senderId, receiverId];
}
