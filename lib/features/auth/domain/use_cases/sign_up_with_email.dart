import 'package:equatable/equatable.dart';
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
  ResultFuture<UserEntity> call(
    SignUpParams params,
  ) =>
      repository.signUpWithEmail(
        params.name,
        params.email,
        params.password,
      );
}

/// **Parameters for Signing Up**
///
/// Includes an email and password.
class SignUpParams extends Equatable {
  const SignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });

  /// Empty constructor for testing purposes.
  const SignUpParams.empty()
      : name = '',
        email = '',
        password = '';
  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}
