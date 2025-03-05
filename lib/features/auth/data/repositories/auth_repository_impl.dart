import 'package:dartz/dartz.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.remoteDataSource);
  AuthRemoteDataSource remoteDataSource;
  @override
  ResultFuture<UserEntity?> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on GetCurrentUserException catch (e) {
      return Left(GetCurrentUserFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UserEntity> signInAnonymously() async {
    try {
      final user = await remoteDataSource.signInAnonymously();
      return Right(user);
    } on SignInException catch (e) {
      return Left(SignInFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UserEntity> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signInWithEmail(email, password);
      return Right(user);
    } on SignInException catch (e) {
      return Left(SignInFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UserEntity> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      return Right(user);
    } on SignInException catch (e) {
      return Left(SignInFailure.fromException(e));
    }
  }

  @override
  ResultVoid signOut() async {
    try {
      final result = await remoteDataSource.signOut();
      return Right(result);
    } on SignOutException catch (e) {
      return Left(SignOutFailure.fromException(e));
    }
  }

  @override
  ResultFuture<UserEntity> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.signUpWithEmail(
        email,
        password,
      );
      return Right(user);
    } on SignUpException catch (e) {
      return Left(SignUpFailure.fromException(e));
    }
  }
}
