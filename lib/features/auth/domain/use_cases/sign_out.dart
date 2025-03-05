import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Sign Out**
///
/// Calls the [AuthRepository] to log out the user.
class SignOut extends UseCase<void> {
  const SignOut(this.repository);

  final AuthRepository repository;

  @override
  ResultVoid call() {
    return repository.signOut();
  }
}
