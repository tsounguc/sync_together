import 'package:equatable/equatable.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfile extends UseCaseWithParams<void, UpdateUserProfileParams> {
  UpdateUserProfile(this.repository);
  final AuthRepository repository;

  @override
  ResultVoid call(UpdateUserProfileParams params) => repository.updateUserProfile(
        action: params.action,
        userData: params.userData,
      );
}

class UpdateUserProfileParams extends Equatable {
  const UpdateUserProfileParams({
    required this.action,
    required this.userData,
  });

  final UpdateUserAction action;
  final dynamic userData;

  @override
  List<Object?> get props => [action, userData];
}
