import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class GetUserById extends UseCaseWithParams<UserEntity, String> {
  const GetUserById(this.repository);
  final WatchPartyRepository repository;
  @override
  ResultFuture<UserEntity> call(
    String params,
  ) =>
      repository.getUserById(params);
}
