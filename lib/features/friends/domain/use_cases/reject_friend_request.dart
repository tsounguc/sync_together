import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class RejectFriendRequest extends UseCaseWithParams<void, FriendRequest> {
  const RejectFriendRequest(this.repository);

  final FriendsRepository repository;

  @override
  ResultFuture<void> call(
    FriendRequest params,
  ) =>
      repository.rejectFriendRequest(request: params);
}
