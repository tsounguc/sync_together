import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendEvent, FriendsState> {
  FriendsBloc({
    required this.getFriends,
    required this.getFriendRequests,
    required this.sendFriendRequest,
    required this.acceptFriendRequest,
    required this.rejectFriendRequest,
    required this.removeFriend,
    required this.searchUsers,
  }) : super(const FriendsInitial()) {
    on<GetFriendsEvent>(_onGetFriends);
    on<GetFriendRequestsEvent>(_onGetFriendRequests);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
    on<RejectFriendRequestEvent>(_onRejectFriendRequest);
    on<RemoveFriendEvent>(_onRemoveFriend);
    on<SearchUsersEvent>(_onSearchUsers);
  }

  final GetFriends getFriends;
  final GetFriendRequests getFriendRequests;
  final SendFriendRequest sendFriendRequest;
  final AcceptFriendRequest acceptFriendRequest;
  final RejectFriendRequest rejectFriendRequest;
  final RemoveFriend removeFriend;
  final SearchUsers searchUsers;

  Future<void> _onGetFriends(
    GetFriendsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await getFriends(event.userId);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (friends) => emit(FriendsLoaded(friends)),
    );
  }

  Future<void> _onGetFriendRequests(
    GetFriendRequestsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await getFriendRequests(event.userId);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (requests) => emit(FriendRequestsLoaded(requests)),
    );
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await sendFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (_) => emit(const FriendRequestSent()),
    );
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await acceptFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (_) => emit(const FriendRequestAccepted()),
    );
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await rejectFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (_) => emit(const FriendRequestRejected()),
    );
  }

  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await removeFriend(
      RemoveFriendParams(
        senderId: event.senderId,
        receiverId: event.receiverId,
      ),
    );
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (_) => emit(const FriendRemoved()),
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(const FriendsLoadingState());
    final result = await searchUsers(event.query);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}
