import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Forgot Password**
///
/// Calls the [AuthRepository] to sent password to email.
class ForgotPassword extends UseCaseWithParams<void, String> {
  const ForgotPassword(this.repository);

  final AuthRepository repository;

  @override
  ResultVoid call(String params) => repository.forgotPassword(params);
}
