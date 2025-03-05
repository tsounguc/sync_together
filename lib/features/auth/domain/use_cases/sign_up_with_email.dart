import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Sign Up with Email & Password**
///
/// Calls the [AuthRepository] to create a new user.
class SignUpWithEmail extends UseCaseWithParams<UserEntity, SignUpParams> {
  const SignUpWithEmail(this.repository);
  final AuthRepository repository;

  @override
  ResultFuture<UserEntity> call(SignUpParams params) {
    return repository.signUpWithEmail(params.email, params.password);
  }
}

/// **Parameters for Signing Up**
///
/// Includes an email and password.
class SignUpParams {
  const SignUpParams({required this.email, required this.password});

  /// Empty constructor for testing purposes.
  const SignUpParams.empty()
      : email = '',
        password = '';

  final String email;
  final String password;
}
