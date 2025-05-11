import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class GetFriendRequests extends UseCaseWithParams<List<FriendRequest>, String> {
  const GetFriendRequests(this.repository);

  final FriendsRepository repository;

  @override
  ResultFuture<List<FriendRequest>> call(
    String params,
  ) =>
      repository.getFriendRequests(params);
}
