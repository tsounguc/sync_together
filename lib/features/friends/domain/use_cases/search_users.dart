import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class SearchUsers extends UseCaseWithParams<List<UserEntity>, String> {
  const SearchUsers(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<List<UserEntity>> call(
    String params,
  ) =>
      repository.searchUsers(params);
}
