import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/data/data_sources/friends_remote_data_source.dart';
import 'package:sync_together/features/friends/data/models/friend_model.dart';
import 'package:sync_together/features/friends/data/models/friend_request_model.dart';
import 'package:sync_together/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/repositories/friends_repository.dart';

class MockFriendsRemoteDataSource extends Mock implements FriendsRemoteDataSource {}

void main() {
  late FriendsRemoteDataSource remoteDataSource;
  late FriendsRepositoryImpl repositoryImpl;
  final testRequest = FriendRequestModel.empty();
  const testUserId = '123';
  final testFriends = <FriendModel>[];
  final testFriendRequests = <FriendRequestModel>[];
  setUp(() {
    remoteDataSource = MockFriendsRemoteDataSource();
    repositoryImpl = FriendsRepositoryImpl(remoteDataSource);
    registerFallbackValue(testRequest);
  });

  test(
    'given FriendsRepositoryImpl '
    'when instantiated '
    'then instance is a subclass of [FriendsRepository] ',
    () async {
      // Arrange
      // Act
      // Assert
      expect(repositoryImpl, isA<FriendsRepository>());
    },
  );

  group('sendFriendRequest - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.sendFriendRequest] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.sendFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await repositoryImpl.sendFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.sendFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.sendFriendRequest] is unsuccessful '
      'then return [SendRequestFailure]',
      () async {
        // Arrange
        const testException = SendRequestException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.sendFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.sendFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            SendRequestFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.sendFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('acceptFriendRequest - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.acceptFriendRequest] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.acceptFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await repositoryImpl.acceptFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.acceptFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.acceptFriendRequest] is unsuccessful '
      'then return [AcceptRequestFailure]',
      () async {
        // Arrange
        const testException = AcceptRequestException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.acceptFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.acceptFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            AcceptRequestFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.acceptFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('rejectFriendRequest - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.rejectFriendRequest] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.rejectFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenAnswer((_) async => Future.value());
        // Act
        final result = await repositoryImpl.rejectFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.rejectFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.rejectFriendRequest] is unsuccessful '
      'then return [RejectRequestFailure]',
      () async {
        // Arrange
        const testException = RejectRequestException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.rejectFriendRequest(
            request: any(named: 'request'),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.rejectFriendRequest(
          request: testRequest,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            RejectRequestFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.rejectFriendRequest(
            request: testRequest,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getFriends - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.getFriends] is called '
      'then return [List<Friend>] ',
      () async {
        // Arrange
        when(
          () => remoteDataSource.getFriends(any()),
        ).thenAnswer((_) async => Future.value(testFriends));

        // Act
        final result = await repositoryImpl.getFriends(
          testUserId,
        );

        // Assert
        expect(
          result,
          Right<Failure, List<Friend>>(testFriends),
        );
        verify(
          () => remoteDataSource.getFriends(
            testUserId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.getFriends] is unsuccessful '
      'then return [GetFriendsFailure]',
      () async {
        // Arrange
        const testException = GetFriendsException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.getFriends(
            any(),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.getFriends(
          testUserId,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            GetFriendsFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.getFriends(testUserId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getFriendRequests - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.getFriendRequests] is called '
      'then return [List<FriendRequest>]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.getFriendRequests(
            any(),
          ),
        ).thenAnswer((_) async => Future.value(testFriendRequests));
        // Act
        final result = await repositoryImpl.getFriendRequests(testUserId);

        // Assert
        expect(
          result,
          Right<Failure, List<FriendRequest>>(testFriendRequests),
        );
        verify(
          () => remoteDataSource.getFriendRequests(testUserId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.getFriendRequests] is unsuccessful '
      'then return [GetFriendRequestsFailure] ',
      () async {
        // Arrange
        const testException = GetFriendRequestsException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.getFriendRequests(
            any(),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.getFriendRequests(
          testUserId,
        );

        // Assert
        expect(
          result,
          Left<Failure, List<FriendRequest>>(
            GetFriendRequestsFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.getFriendRequests(testUserId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('removeFriend - ', () {
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.removeFriend] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.removeFriend(
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.removeFriend(
          senderId: testRequest.senderId,
          receiverId: testRequest.receiverId,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.removeFriend(
            senderId: testRequest.senderId,
            receiverId: testRequest.receiverId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.sendFriendRequest] is unsuccessful '
      'then return [RemoveFriendFailure]',
      () async {
        // Arrange
        const testException = RemoveFriendException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.removeFriend(
            senderId: any(named: 'senderId'),
            receiverId: any(named: 'receiverId'),
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.removeFriend(
          senderId: testRequest.senderId,
          receiverId: testRequest.receiverId,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            RemoveFriendFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.removeFriend(
            senderId: testRequest.senderId,
            receiverId: testRequest.receiverId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('searchUsers - ', () {
    const testQuery = 'user1';
    final testUsers = <UserModel>[];
    test(
      'given FriendsRepositoryImpl, '
      'when [FriendsRemoteDataSource.searchUsers] is called '
      'then return [List<UserEntity>]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.searchUsers(testQuery),
        ).thenAnswer((_) async => Future.value(testUsers));
        // Act
        final result = await repositoryImpl.searchUsers(
          testQuery,
        );

        // Assert
        expect(result, Right<Failure, List<UserEntity>>(testUsers));
        verify(
          () => remoteDataSource.searchUsers(
            testQuery,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given FriendsRepositoryImpl, '
      'when call [FriendsRemoteDataSource.sendFriendRequest] is unsuccessful '
      'then return [SearchUsersFailure]',
      () async {
        // Arrange
        const testException = SearchUsersException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.searchUsers(
            testQuery,
          ),
        ).thenThrow(testException);
        // Act
        final result = await repositoryImpl.searchUsers(
          testQuery,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            SearchUsersFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.searchUsers(
            testQuery,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
}
