import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Sign In Anonymously**
///
/// Calls the [AuthRepository] to authenticate a user without credentials.
class SignInAnonymously extends UseCase<UserEntity> {
  const SignInAnonymously(this.repository);

  final AuthRepository repository;

  @override
  ResultFuture<UserEntity> call() {
    return repository.signInAnonymously();
  }
}
