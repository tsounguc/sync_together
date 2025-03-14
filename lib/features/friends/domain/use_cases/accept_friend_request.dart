import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class AcceptFriendRequest extends UseCaseWithParams<void, String> {
  const AcceptFriendRequest(this.repository);

  final FriendRepository repository;

  @override
  ResultFuture<void> call(
    String params,
  ) =>
      repository.acceptFriendRequest(requestId: params);
}
