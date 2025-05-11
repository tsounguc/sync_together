import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/data/data_sources/friends_remote_data_source.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  FriendsRepositoryImpl(this.remoteDataSource);

  final FriendsRemoteDataSource remoteDataSource;

  @override
  ResultVoid sendFriendRequest({required FriendRequest request}) async {
    try {
      final result = await remoteDataSource.sendFriendRequest(request: request);

      return Right(result);
    } on SendRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(SendRequestFailure.fromException(e));
    }
  }

  @override
  ResultVoid acceptFriendRequest({required FriendRequest request}) async {
    try {
      final result = await remoteDataSource.acceptFriendRequest(
        request: request,
      );
      return Right(result);
    } on AcceptRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(AcceptRequestFailure.fromException(e));
    }
  }

  @override
  ResultVoid rejectFriendRequest({required FriendRequest request}) async {
    try {
      final result = await remoteDataSource.rejectFriendRequest(
        request: request,
      );
      return Right(result);
    } on RejectRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(RejectRequestFailure.fromException(e));
    }
  }

  @override
  ResultFuture<List<Friend>> getFriends(String userId) async {
    try {
      final result = await remoteDataSource.getFriends(userId);
      return Right(result);
    } on GetFriendsException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(GetFriendsFailure.fromException(e));
    }
  }

  @override
  ResultFuture<List<FriendRequest>> getFriendRequests(String userId) async {
    try {
      final result = await remoteDataSource.getFriendRequests(userId);
      return Right(result);
    } on GetFriendRequestsException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(GetFriendRequestsFailure.fromException(e));
    }
  }

  @override
  ResultVoid removeFriend({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final result = await remoteDataSource.removeFriend(
        senderId: senderId,
        receiverId: receiverId,
      );
      return Right(result);
    } on RemoveFriendException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(RemoveFriendFailure.fromException(e));
    }
  }

  @override
  ResultFuture<List<UserEntity>> searchUsers(String query) async {
    try {
      final result = await remoteDataSource.searchUsers(query);
      return Right(result);
    } on SearchUsersException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(SearchUsersFailure.fromException(e));
    }
  }
}
