import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class RejectFriendRequest extends UseCaseWithParams<void, FriendRequest> {
  const RejectFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(
    FriendRequest params,
  ) =>
      repository.rejectFriendRequest(request: params);
}
