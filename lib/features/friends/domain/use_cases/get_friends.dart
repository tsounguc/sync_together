import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class GetFriends extends UseCaseWithParams<List<Friend>, String> {
  const GetFriends(this.repository);

  final FriendsRepository repository;

  @override
  ResultFuture<List<Friend>> call(
    String params,
  ) =>
      repository.getFriends(params);
}
