import 'package:equatable/equatable.dart';

/// Represents a confirmed friendship between two users.
class Friend extends Equatable {
  /// Constructor for the [Friend].
  const Friend({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
  });

  /// The unique ID of the friendship document.
  final String id;

  /// The user ID of the first friend.
  final String user1Id;

  /// The user ID of the second friend.
  final String user2Id;

  /// The date when the friendship was established.
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, user1Id, user2Id, createdAt];
}
