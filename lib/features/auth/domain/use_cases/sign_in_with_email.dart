import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

/// **Use Case: Sign In with Email & Password**
///
/// Calls the [AuthRepository] to authenticate the user.
class SignInWithEmail extends UseCaseWithParams<UserEntity, SignInParams> {
  const SignInWithEmail(this.repository);
  final AuthRepository repository;

  @override
  ResultFuture<UserEntity> call(SignInParams params) {
    return repository.signInWithEmail(params.email, params.password);
  }
}

/// **Parameters for Signing In**
///
/// Includes an email and password.
class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  /// Empty constructor for testing purposes.
  const SignInParams.empty()
      : email = '',
        password = '';

  /// Email of user
  final String email;

  /// Password of user
  final String password;

  @override
  List<Object?> get props => [email, password];
}
