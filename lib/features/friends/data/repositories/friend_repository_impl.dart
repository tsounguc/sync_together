import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/data/data_sources/friend_remote_data_source.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  FriendRepositoryImpl(this.remoteDataSource);

  final FriendRemoteDataSource remoteDataSource;

  @override
  ResultVoid acceptFriendRequest({required String requestId}) async {
    try {
      final result = await remoteDataSource.acceptFriendRequest(
        requestId: requestId,
      );
      return Right(result);
    } on AcceptRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(AcceptRequestFailure.fromException(e));
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
  ResultVoid rejectFriendRequest({required String requestId}) async {
    try {
      final result = await remoteDataSource.rejectFriendRequest(
        requestId: requestId,
      );
      return Right(result);
    } on RejectRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(RejectRequestFailure.fromException(e));
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
  ResultVoid sendFriendRequest({
    required String senderId,
    required String receivedId,
  }) async {
    try {
      final result = await remoteDataSource.sendFriendRequest(
        senderId: senderId,
        receiverId: receivedId,
      );

      return Right(result);
    } on SendRequestException catch (e, s) {
      debugPrintStack(label: e.message, stackTrace: s);
      return Left(SendRequestFailure.fromException(e));
    }
  }
}
