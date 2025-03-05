import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Get Current User**
///
/// Calls the [AuthRepository] to retrieve the currently authenticated user.
class GetCurrentUser extends UseCase<UserEntity?> {
  const GetCurrentUser(this.repository);

  final AuthRepository repository;

  @override
  ResultFuture<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}
