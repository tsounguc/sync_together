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

part 'friend_event.dart';
part 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  FriendBloc({
    required this.getFriends,
    required this.getFriendRequests,
    required this.sendFriendRequest,
    required this.acceptFriendRequest,
    required this.rejectFriendRequest,
    required this.removeFriend,
    required this.searchUsers,
  }) : super(const FriendInitial()) {
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
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await getFriends(event.userId);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (friends) => emit(FriendsLoaded(friends)),
    );
  }

  Future<void> _onGetFriendRequests(
    GetFriendRequestsEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await getFriendRequests(event.userId);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (requests) => emit(FriendRequestsLoaded(requests)),
    );
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await sendFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (_) => emit(const FriendRequestSent()),
    );
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await acceptFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (_) => emit(const FriendRequestAccepted()),
    );
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await rejectFriendRequest(event.request);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (_) => emit(const FriendRequestRejected()),
    );
  }

  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendState> emit,
  ) async {
    emit(const FriendLoading());
    final result = await removeFriend(
      RemoveFriendRequestParams(
        senderId: event.senderId,
        receiverId: event.receiverId,
      ),
    );
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (_) => emit(const FriendRemoved()),
    );
  }

  Future<void> _onSearchUsers(SearchUsersEvent event, Emitter<FriendState> emit) async {
    emit(const FriendLoading());
    final result = await searchUsers(event.query);
    result.fold(
      (failure) => emit(FriendError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}
