import 'package:equatable/equatable.dart';

/// Represents a Friend Request in the Friends System.
class FriendRequest extends Equatable {
  /// Constructor for [FriendRequest] entity.
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.sentAt,
  });

  /// The unique ID of the friend request document.
  final String id;

  /// The user ID of the sender.
  final String senderId;

  /// The user ID of the receiver.
  final String receiverId;

  /// The timestamp when the friend request was sent.
  final DateTime sentAt;

  @override
  List<Object?> get props => [senderId, receiverId, sentAt];
}
