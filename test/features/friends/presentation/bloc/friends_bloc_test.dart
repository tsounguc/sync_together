import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';
import 'package:sync_together/features/friends/domain/entities/friend_request.dart';
import 'package:sync_together/features/friends/domain/use_cases/accept_friend_request.dart';
import 'package:sync_together/features/friends/domain/use_cases/get_friend_requests.dart';
import 'package:sync_together/features/friends/domain/use_cases/get_friends.dart';
import 'package:sync_together/features/friends/domain/use_cases/reject_friend_request.dart';
import 'package:sync_together/features/friends/domain/use_cases/remove_friend.dart';
import 'package:sync_together/features/friends/domain/use_cases/search_users.dart';
import 'package:sync_together/features/friends/domain/use_cases/send_friend_request.dart';
import 'package:sync_together/features/friends/presentation/friends_bloc/friends_bloc.dart';

class MockGetFriends extends Mock implements GetFriends {}

class MockGetFriendRequests extends Mock implements GetFriendRequests {}

class MockSendFriendRequest extends Mock implements SendFriendRequest {}

class MockAcceptFriendRequest extends Mock implements AcceptFriendRequest {}

class MockRejectFriendRequest extends Mock implements RejectFriendRequest {}

class MockRemoveFriend extends Mock implements RemoveFriend {}

class MockSearchUsers extends Mock implements SearchUsers {}

void main() {
  late GetFriends getFriends;
  late GetFriendRequests getFriendRequests;
  late SendFriendRequest sendFriendRequest;
  late AcceptFriendRequest acceptFriendRequest;
  late RejectFriendRequest rejectFriendRequest;
  late RemoveFriend removeFriend;
  late SearchUsers searchUsers;

  late FriendsBloc bloc;

  late RemoveFriendParams removeFriendParams;

  late GetFriendsFailure testGetFriendsFailure;
  late GetFriendRequestsFailure testGetFriendRequestsFailure;
  late SendRequestFailure testSendRequestFailure;
  late AcceptRequestFailure testAcceptRequestFailure;
  late RejectRequestFailure testRejectRequestFailure;
  late RemoveFriendFailure testRemoveFriendFailure;
  late SearchUsersFailure testSearchUserFailure;

  final testFriends = <Friend>[];
  final testFriendRequests = <FriendRequest>[];
  final testRequest = FriendRequest.empty();
  const testUser = UserEntity.empty();

  setUp(() {
    getFriends = MockGetFriends();
    getFriendRequests = MockGetFriendRequests();
    sendFriendRequest = MockSendFriendRequest();
    acceptFriendRequest = MockAcceptFriendRequest();
    rejectFriendRequest = MockRejectFriendRequest();
    removeFriend = MockRemoveFriend();
    searchUsers = MockSearchUsers();

    bloc = FriendsBloc(
      getFriends: getFriends,
      getFriendRequests: getFriendRequests,
      sendFriendRequest: sendFriendRequest,
      acceptFriendRequest: acceptFriendRequest,
      rejectFriendRequest: rejectFriendRequest,
      removeFriend: removeFriend,
      searchUsers: searchUsers,
    );

    testGetFriendsFailure = GetFriendsFailure(
      message: 'message',
      statusCode: 500,
    );
    testGetFriendRequestsFailure = GetFriendRequestsFailure(
      message: 'message',
      statusCode: 500,
    );
    testSendRequestFailure = SendRequestFailure(
      message: 'message',
      statusCode: 500,
    );
    testAcceptRequestFailure = AcceptRequestFailure(
      message: 'message',
      statusCode: 500,
    );
    testRejectRequestFailure = RejectRequestFailure(
      message: 'message',
      statusCode: 500,
    );
    testRemoveFriendFailure = RemoveFriendFailure(
      message: 'message',
      statusCode: 500,
    );
    testSearchUserFailure = SearchUsersFailure(
      message: 'message',
      statusCode: 500,
    );
  });

  setUpAll(() {
    removeFriendParams = const RemoveFriendParams.empty();
    registerFallbackValue(removeFriendParams);
    registerFallbackValue(testRequest);
  });

  tearDown(() => bloc.close());

  test(
      'given FriendsBloc '
      'when bloc is instantiated '
      'then initial state should be [FriendsInitial] ', () async {
    // Arrange
    // Act
    // Assert
    expect(bloc.state, const FriendsInitial());
  });

  group('getFriends - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.getFriends] is called '
      'then emit [FriendsLoadingState, FriendsLoaded]',
      build: () {
        when(
          () => getFriends(any()),
        ).thenAnswer((_) async => Right(testFriends));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetFriendsEvent(userId: testUser.uid),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsLoaded(testFriends),
      ],
      verify: (bloc) {
        verify(
          () => getFriends(testUser.uid),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.getFriends] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => getFriends(any()),
        ).thenAnswer((_) async => Left(testGetFriendsFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetFriendsEvent(userId: testUser.uid),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testGetFriendsFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => getFriends(testUser.uid),
        ).called(1);
      },
    );
  });
  group('getFriendRequests - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.getFriendRequests] is called '
      'then emit [FriendsLoadingState, FriendRequestsLoaded]',
      build: () {
        when(
          () => getFriendRequests(any()),
        ).thenAnswer((_) async => Right(testFriendRequests));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetFriendRequestsEvent(userId: testUser.uid),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendRequestsLoaded(testFriendRequests),
      ],
      verify: (bloc) {
        verify(
          () => getFriendRequests(testUser.uid),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.getFriendRequests] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => getFriendRequests(any()),
        ).thenAnswer((_) async => Left(testGetFriendRequestsFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetFriendRequestsEvent(userId: testUser.uid),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testGetFriendRequestsFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => getFriendRequests(testUser.uid),
        ).called(1);
      },
    );
  });
  group('sendFriendRequest - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.sendFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendRequestsLoaded]',
      build: () {
        when(
          () => sendFriendRequest(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SendFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        const FriendRequestSent(),
      ],
      verify: (bloc) {
        verify(
          () => sendFriendRequest(testRequest),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.sendFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => sendFriendRequest(any()),
        ).thenAnswer((_) async => Left(testSendRequestFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SendFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testSendRequestFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => sendFriendRequest(testRequest),
        ).called(1);
      },
    );
  });
  group('acceptFriendRequest - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.acceptFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendRequestsAccepted]',
      build: () {
        when(
          () => acceptFriendRequest(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        AcceptFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        const FriendRequestAccepted(),
      ],
      verify: (bloc) {
        verify(
          () => acceptFriendRequest(testRequest),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.acceptFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => acceptFriendRequest(any()),
        ).thenAnswer((_) async => Left(testAcceptRequestFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        AcceptFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testAcceptRequestFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => acceptFriendRequest(testRequest),
        ).called(1);
      },
    );
  });
  group('rejectFriendRequest - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.rejectFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendRequestsRejected]',
      build: () {
        when(
          () => rejectFriendRequest(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        RejectFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        const FriendRequestRejected(),
      ],
      verify: (bloc) {
        verify(
          () => rejectFriendRequest(testRequest),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.rejectFriendRequest] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => rejectFriendRequest(any()),
        ).thenAnswer((_) async => Left(testRejectRequestFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        RejectFriendRequestEvent(testRequest),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testRejectRequestFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => rejectFriendRequest(testRequest),
        ).called(1);
      },
    );
  });
  group('removeFriend - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.removeFriend] is called '
      'then emit [FriendsLoadingState, FriendRemoved]',
      build: () {
        when(
          () => removeFriend(any()),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        RemoveFriendEvent(
          senderId: removeFriendParams.senderId,
          receiverId: removeFriendParams.receiverId,
        ),
      ),
      expect: () => [
        const FriendsLoadingState(),
        const FriendRemoved(),
      ],
      verify: (bloc) {
        verify(
          () => removeFriend(removeFriendParams),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.removeFriend] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => removeFriend(any()),
        ).thenAnswer((_) async => Left(testRemoveFriendFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        RemoveFriendEvent(
          senderId: removeFriendParams.senderId,
          receiverId: removeFriendParams.receiverId,
        ),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testRemoveFriendFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => removeFriend(removeFriendParams),
        ).called(1);
      },
    );
  });
  group('searchUsers - ', () {
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.searchUsers] is called '
      'then emit [FriendsLoadingState, UsersLoaded]',
      build: () {
        when(
          () => searchUsers(any()),
        ).thenAnswer((_) async => const Right([testUser]));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SearchUsersEvent(
          query: 'testUser.displayName',
        ),
      ),
      expect: () => [
        const FriendsLoadingState(),
        const UsersLoaded([testUser]),
      ],
      verify: (bloc) {
        verify(
          () => searchUsers('testUser.displayName'),
        ).called(1);
      },
    );
    blocTest<FriendsBloc, FriendsState>(
      'given FriendsBloc '
      'when [FriendsBloc.searchUsers] is called '
      'then emit [FriendsLoadingState, FriendsError]',
      build: () {
        when(
          () => searchUsers(any()),
        ).thenAnswer((_) async => Left(testSearchUserFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const SearchUsersEvent(
          query: 'testUser.displayName',
        ),
      ),
      expect: () => [
        const FriendsLoadingState(),
        FriendsError(testSearchUserFailure.message),
      ],
      verify: (bloc) {
        verify(
          () => searchUsers('testUser.displayName'),
        ).called(1);
      },
    );
  });
}
